//
//  ViewController.swift
//  Open Backup Extractor
//
//  Created by vgm on 8/26/17.
//  Copyright © 2017 VGMoose. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

	// the table view link from story board
	@IBOutlet weak var tableView: NSTableView!
	
	// the dim text before a device is selected
	@IBOutlet weak var placeholderText: NSTextField!
	
	// the list of all devices
	var devices: [Device] = []
	
	// the path to the itunes library
	let ITUNES_BACKUP_PATH = NSHomeDirectory() + "/Library/Application Support/MobileSync/Backup/"
	
	// the number of cell that is being loaded
	var curentCellIndex = 0
	
	// the textbox that displays the selected export path
	@IBOutlet weak var exportFolderPathField: NSTextField!
	
	override func loadView()
	{
		super.loadView()
		
		// set this view controller to the app delegate
		let appDelegate = NSApplication.shared().delegate as! AppDelegate
		appDelegate.mainViewController = self

		// set the height of every cell in the table
		tableView.rowHeight = 70
		
		// refresh the device list on the first launch
		refreshDevices()
		
		self.tableView.action = #selector(onItemClicked)

	}
	
	@objc private func onItemClicked()
	{
		// hide the placeholder text
		self.placeholderText.isHidden = true
	}

	@IBAction func getHelp(_ sender: Any) {
			dialog("Open Backup Extractor", "I made this tool out of frustration with existing solutions that all wanted to charge money to export files, specifically voicemails.\n\nThe idea is you perform a backup of the iOS device in iTunes, and then run this application or hit refresh. It should appear alongside the left hand side.\n\nWhen you choose it, you can then select the types of files that you want to extract from the backup. These are located in \"~/Library/Application Support/MobileSync/Backup/\".\n\nThis tool only copies the files of certain types from that folder into a destination folder that you specify.\n\nIt is limited in functionality, but it should get the job done! If you encounter any issue, please contact me or file an issue on Github (see the source code).")
	}
	
	@IBAction func refeshButton(_ sender: NSButton) {
		
		// clear the device list
		self.devices = []
		refreshDevices();
	}
	
	func refreshDevices()
	{
		do
		{
			// get an enumerator for the itunes backup path
			let files = try FileManager.default.contentsOfDirectory(atPath: ITUNES_BACKUP_PATH)
			
			// go through every file in that folder
			for file in files
			{
				// check if the current path is a folder
				var isDir : ObjCBool = false
				FileManager.default.fileExists(atPath: ITUNES_BACKUP_PATH + file, isDirectory:&isDir)
				
				if isDir.boolValue
				{
					// if it's a folder, try to load it as a device cell
					let device = Device()
					
					if device.load(ITUNES_BACKUP_PATH + file)
					{
						// if it loaded, append it to the devices list
						devices.append(device)
					}
				}
			}
			
			// reload the table view
			reloadData()
		}
		catch
		{
			// do nothing, the file list will be empty
		}
		
	}
	
	@IBAction func chooseExportFolder(_ sender: NSButton)
	{
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseDirectories = true
		openPanel.canCreateDirectories = true
		openPanel.canChooseFiles = false
		openPanel.begin { (result) -> Void in
			if result == NSFileHandlingPanelOKButton {
				self.exportFolderPathField.stringValue = (openPanel.url?.absoluteString)!
			}
		}
	}
	
	func reloadData()
	{
		// reset the cell index counter
		self.curentCellIndex = 0
		
		// reload the actual table view
		tableView.reloadData()
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int
	{
		return devices.count
	}

	@IBAction func openSourceCode(_ sender: NSButton)
	{
		// open up the source page for this project
		NSWorkspace.shared().open(URL(string: "https://github.com/vgmoose/openbackupextractor")!)
	}
	
	// display alert (from https://stackoverflow.com/a/29433631/1137828 )
	func dialog(_ question: String, _ text: String) {
		let alert = NSAlert()
		alert.messageText = question
		alert.informativeText = text
		alert.alertStyle = .warning
		alert.addButton(withTitle: "OK")
		alert.beginSheetModal(for: self.view.window!)
	}
	
}

