package com.example.telemetry_core

import android.Manifest
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
	private val gpsChannelName = "telemetry_core/telemetria_gps"
	private val locationPermissionRequestCode = 1001

	private var locationManager: LocationManager? = null
	private var eventSink: EventChannel.EventSink? = null
	private var gpsListener: LocationListener? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		locationManager = getSystemService(LOCATION_SERVICE) as LocationManager

		EventChannel(flutterEngine.dartExecutor.binaryMessenger, gpsChannelName)
			.setStreamHandler(
				object : EventChannel.StreamHandler {
					override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
						eventSink = events
						startGpsUpdates()
					}

					override fun onCancel(arguments: Any?) {
						stopGpsUpdates()
						eventSink = null
					}
				}
			)
	}

	private fun hasLocationPermission(): Boolean {
		val fine = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
		val coarse = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
		return fine == PackageManager.PERMISSION_GRANTED || coarse == PackageManager.PERMISSION_GRANTED
	}

	private fun startGpsUpdates() {
		val manager = locationManager ?: return

		if (!hasLocationPermission()) {
			ActivityCompat.requestPermissions(
				this,
				arrayOf(
					Manifest.permission.ACCESS_FINE_LOCATION,
					Manifest.permission.ACCESS_COARSE_LOCATION
				),
				locationPermissionRequestCode
			)
			return
		}

		if (gpsListener != null) return

		gpsListener = LocationListener { location: Location ->
			val lat = String.format(Locale.US, "%.5f", location.latitude)
			val lon = String.format(Locale.US, "%.5f", location.longitude)
			eventSink?.success("$lat , $lon")
		}

		try {
			manager.requestLocationUpdates(
				LocationManager.GPS_PROVIDER,
				1000L,
				0f,
				gpsListener as LocationListener
			)
		} catch (securityException: SecurityException) {
			eventSink?.error("PERMISSION_DENIED", "Permissao de localizacao negada", null)
		} catch (exception: Exception) {
			eventSink?.error("GPS_ERROR", "Falha ao iniciar GPS: ${exception.message}", null)
		}
	}

	private fun stopGpsUpdates() {
		val manager = locationManager ?: return
		val listener = gpsListener ?: return

		manager.removeUpdates(listener)
		gpsListener = null
	}

	override fun onRequestPermissionsResult(
		requestCode: Int,
		permissions: Array<out String>,
		grantResults: IntArray
	) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)

		if (requestCode == locationPermissionRequestCode) {
			if (grantResults.isNotEmpty() && grantResults.any { it == PackageManager.PERMISSION_GRANTED }) {
				startGpsUpdates()
			} else {
				eventSink?.error("PERMISSION_DENIED", "Permissao de localizacao negada", null)
			}
		}
	}

	override fun onDestroy() {
		stopGpsUpdates()
		super.onDestroy()
	}
}
