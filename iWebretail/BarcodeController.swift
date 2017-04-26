//
//  SecondViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 12/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import AVFoundation
import UIKit

class BarcodeController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!
	var movement: Movement!
	
	private var repository: MovementArticleProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementArticleProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//view.backgroundColor = UIColor.black
		captureSession = AVCaptureSession()
		
		let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		let videoInput: AVCaptureDeviceInput
		
		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
		} catch {
			return
		}
		
		if (captureSession.canAddInput(videoInput)) {
			captureSession.addInput(videoInput)
		} else {
			failed();
			return;
		}
		
		let metadataOutput = AVCaptureMetadataOutput()
		
		if (captureSession.canAddOutput(metadataOutput)) {
			captureSession.addOutput(metadataOutput)
			
			metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code]
		} else {
			failed()
			return
		}
		
		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
		previewLayer.frame = view.layer.bounds;
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		view.layer.addSublayer(previewLayer);
		
		captureSession.startRunning();
	}
	
	func failed() {
		let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
		captureSession = nil
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		found(code: "1000000000002")
		//read()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if (captureSession?.isRunning == true) {
			captureSession.stopRunning();
		}
	}
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
		captureSession.stopRunning()
		
		if let metadataObject = metadataObjects.first {
			let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
			
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			found(code: readableObject.stringValue);
		}
		
		dismiss(animated: true)
	}
	
	func read() {
		if (captureSession?.isRunning == false) {
			captureSession.startRunning();
		}
	}
	
	func found(code: String) {
		print(code)
		do {
			_ = try repository.add(barcode: code, movementId: movement.movementId)
		} catch {
			print("Error on add barcode: \(error)")
		}
		
		read()
	}
	
	/*
	// MARK: - Navigation
	func addItem(barcode: String) {

		let firstView = storyboard?.instantiateViewController(withIdentifier: "FirstView") as! FirstViewController
		firstView.items.append(barcode)
		navigationController?.pushViewController(firstView, animated: true)
	}
	*/
}