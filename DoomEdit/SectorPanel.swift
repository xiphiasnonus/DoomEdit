//
//  SectorPanel.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/15/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

protocol FlatPanelDelegate {
	func updatePanel(for position: Int, with index: Int)
}

class SectorPanel: NSViewController, NSTextDelegate, FlatPanelDelegate {
	
	var def = SectorDef()
	var selectedLineIndices: [Int] = []
//	var wad = WadFile()
	
	@IBOutlet weak var sectorLabel: NSTextField!
	@IBOutlet weak var ceilingHeightTextField: NSTextField!
	@IBOutlet weak var floorHeightTextField: NSTextField!
	@IBOutlet weak var heightLabel: NSTextField!
	@IBOutlet weak var tagTextField: NSTextField!
	@IBOutlet weak var lightTextField: NSTextField!
	@IBOutlet weak var lightSlider: NSSlider!
	@IBOutlet weak var ceilingImageView: FlatImageView!
	@IBOutlet weak var floorImageView: FlatImageView!
	@IBOutlet weak var ceilingLabel: NSTextField!
	@IBOutlet weak var floorLabel: NSTextField!
	@IBOutlet weak var specialButton: NSPopUpButton!
	@IBOutlet weak var specialTextField: NSTextField!
	
	
	
	// =======================
	// MARK: - View Life Cycle
	// =======================
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		ceilingImageView.flatPanel.delegate = self
		floorImageView.flatPanel.delegate = self
		
		ceilingImageView.flatPosition = 1
		floorImageView.flatPosition = 0
		
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		// TODO: Get the sector number
		sectorLabel.stringValue = "Sector Properties"
		ceilingHeightTextField.integerValue = def.ceilingHeight
		floorHeightTextField.integerValue = def.floorHeight
		heightLabel.integerValue = def.ceilingHeight - def.floorHeight
		tagTextField.integerValue = def.tag
		lightTextField.integerValue = def.lightLevel
		lightSlider.integerValue = def.lightLevel
		ceilingLabel.stringValue = def.ceilingFlat
		floorLabel.stringValue = def.floorFlat
		specialTextField.integerValue = def.special
		specialButton.selectItem(withTag: def.special)
		
		// Send the current flat indices.
		ceilingImageView.selectedFlatIndex = indexForFlat(named: def.ceilingFlat)
		floorImageView.selectedFlatIndex = indexForFlat(named: def.floorFlat)

		// Set the image views with current flats
		ceilingImageView.image = imageNamed(def.ceilingFlat)
		floorImageView.image = imageNamed(def.floorFlat)
		
		// Store the currently selected line so they can be set on viewWillDisappear
		selectedLineIndices = []
		for i in 0..<lines.count {
			if lines[i].selected < 1 {
				continue
			} else if lines[i].selected == 1 {
				selectedLineIndices.append(i)
			} else if lines[i].selected == 2 {
				selectedLineIndices.append(i | SIDE_BIT)
			}
		}
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()

		def.ceilingHeight = ceilingHeightTextField.integerValue
		def.floorHeight = floorHeightTextField.integerValue
		def.tag = tagTextField.integerValue
		def.lightLevel = lightTextField.integerValue
		def.special = specialTextField.integerValue
		def.ceilingFlat = ceilingLabel.stringValue
		def.floorFlat = floorLabel.stringValue
		
		fillSector()
	}
	
	/// Look up the image for the flat name. Called to update the floor/ceiling image views
	func imageNamed(_ name: String) -> NSImage? {
		
		for flat in wad.flats {
			if flat.name == name {
				return flat.image
			}
		}
		return nil
	}
	
	/// Look up the index of the flat with given name. Called to send selection index to texture panel (via imageview).
	func indexForFlat(named name: String) -> Int {
		
		for flat in wad.flats {
			if flat.name == name {
				return flat.index
			}
		}
		return -1
	}
	
	/// Set all the selected lines with the new sector def.
	func fillSector() {
		
		var i: Int = 0
		var side: Int = 0
		
		for index in selectedLineIndices {
			i = index
			if index & SIDE_BIT != 0 {
				i &= ~SIDE_BIT
				lines[i].side[1]?.ends = def
			} else {
				lines[i].side[0]?.ends = def
			}
		}
//		for i in 0..<lines.count {
//			if lines[i].selected < 1 {
//				continue }
//			side = lines[i].selected - 1
//			lines[i].side[side]?.ends = def
//		}
		doomProject.setDirtyMap(true)
		
		
//		for i in 0..<lines.count {
//			if selectedSides[i] & SIDE_BIT == SIDE_BIT {
//				var line = selectedSides[i]
//				line &= ~SIDE_BIT
//				lines[line].side[1]?.ends = def
//			} else {
//				let line = selectedSides[i]
//				lines[line].side[0]?.ends = def
//			}
//		}
	}
	
	/// Set the name and image view with the flat selected in the flat panel.
	func updatePanel(for position: Int, with index: Int) {
		
		switch position {
		case 0:
			floorLabel.stringValue = wad.flats[index].name
			floorImageView.image = wad.flats[index].image
			floorImageView.selectedFlatIndex = wad.flats[index].index
		case 1:
			ceilingLabel.stringValue = wad.flats[index].name
			ceilingImageView.image = wad.flats[index].image
			ceilingImageView.selectedFlatIndex = wad.flats[index].index
		default:
			fatalError("Invalid FlatImageView position!")
		}
	}
	
	
	// =================
	// MARK: - IBActions
	// =================

	@IBAction func suggestTagClicked(_ sender: NSButton) {

		var maxTag = 0
		
		for line in lines {
			for side in line.side {
				if let tag = side?.ends.tag {
					if tag > maxTag {
						maxTag = tag
					}
				}
			}
		}
		
		tagTextField.integerValue = maxTag + 1
	}
	
	
	
	@IBAction func specialChanged(_ sender: NSPopUpButton) {
		specialTextField.integerValue = sender.selectedItem?.tag ?? 0
	}
	
}
