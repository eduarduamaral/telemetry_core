import Flutter
import UIKit
import CoreLocation

class SceneDelegate: FlutterSceneDelegate {
	private var gpsChannel: FlutterEventChannel?
	private let gpsStreamHandler = GpsStreamHandler()

	override func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		super.scene(scene, willConnectTo: session, options: connectionOptions)

		guard let controller = window?.rootViewController as? FlutterViewController else {
			return
		}

		gpsChannel = FlutterEventChannel(
			name: "telemetry_core/telemetria_gps",
			binaryMessenger: controller.binaryMessenger
		)
		gpsChannel?.setStreamHandler(gpsStreamHandler)
	}
}

final class GpsStreamHandler: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
	private var eventSink: FlutterEventSink?
	private let locationManager = CLLocationManager()

	func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
		eventSink = events

		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()

		return nil
	}

	func onCancel(withArguments arguments: Any?) -> FlutterError? {
		locationManager.stopUpdatingLocation()
		eventSink = nil
		return nil
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }

		let lat = String(format: "%.5f", location.coordinate.latitude)
		let lon = String(format: "%.5f", location.coordinate.longitude)
		eventSink?("\(lat) , \(lon)")
	}
}
