//
//  FlatPanel.swift
//  DoomEdit
//
//  Created by Thomas Foster on 1/13/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

import Cocoa

fileprivate let SPACING: CGFloat = 5.0

/**
Displays all the WAD's flats in a collection view.
*/

class FlatPanel: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
	
	var flatPosition = 0
	var selectedFlatIndex = -1
	var selectedFlatName = ""
	
	var window: NSWindow?
	var delegate: FlatPanelDelegate?
	
	var filteredFlats: [Flat] = []
	
	@IBOutlet weak var collectionView: NSCollectionView!
	@IBOutlet weak var nameLabel: NSTextField!
	@IBOutlet weak var searchField: NSSearchField!
	

	
	// =================================
	// MARK: - ViewController Life Cycle
	// =================================

    override func viewDidLoad() {
        super.viewDidLoad()
		
		filteredFlats = doomData.doom1Flats
		
		searchField.sendsSearchStringImmediately = true
		searchField.sendsWholeSearchString = false
		
		collectionView.dataSource = self
		collectionView.delegate = self
		configureCollectionView()
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		window = self.view.window
		searchField.stringValue = ""
		filteredFlats = doomData.doom1Flats
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
		
		selectFlat()
	}
	
	
	
	// ======================
	// MARK: - Helper Methods
	// ======================
	
	fileprivate func configureCollectionView() {
		
		collectionView.isSelectable = true
		collectionView.allowsEmptySelection = false
		collectionView.allowsMultipleSelection = false
		
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.scrollDirection = .vertical
		flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 20.0)
		flowLayout.minimumInteritemSpacing = 0.0
		flowLayout.minimumLineSpacing = 0.0

		collectionView.collectionViewLayout = flowLayout
		
		view.wantsLayer = true
		collectionView.layer?.backgroundColor = NSColor.black.cgColor
	}
	
	func indexSet(for item: Int) -> Set<IndexPath> {
		let indexPath = IndexPath(item: item, section: 0)
		let indexSet: Set = [indexPath]
		return indexSet
	}
	

	
	// =============
	// MARK: - Flats
	// =============

	func selectFlat() {
		
		collectionView.deselectAll(nil)
		
		for i in 0..<filteredFlats.count {
			if filteredFlats[i].index == selectedFlatIndex {
				collectionView.selectItems(at: indexSet(for: i), scrollPosition: .centeredVertically)
				updateLabel(texture: filteredFlats[i].name)
				return
			}
		}
	}
	
	func setFlat() {
		delegate?.updatePanel(for: flatPosition, with: selectedFlatName)
	}

	func updateLabel(texture: String) {
		nameLabel.stringValue = texture
	}

	
	
	
	// =======================
	// MARK: - Collection View
	// =======================

	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return filteredFlats.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
				
		let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FlatCollectionViewItem"), for: indexPath)
		guard let collectionViewItem = item as? FlatCollectionViewItem else { return item }
		
		let flat = filteredFlats[indexPath.item]
		
		collectionViewItem.imageView?.image = flat.image
		
		return item
	}
	
	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		var size = NSSize()
		size.width = 64+(SPACING*2)
		size.height = 64+(SPACING*2)
		return size
	}

	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		
		var selectedFlat = Flat()
		
		for indexPath in indexPaths {
			selectedFlat = filteredFlats[indexPath.item]
			selectedFlatIndex = selectedFlat.index
		}
		updateLabel(texture: selectedFlat.name)
		selectedFlatName = selectedFlat.name
	}
	
	
	
	// =================
	// MARK: - IBActions
	// =================
	
	@IBAction func setClicked(_ sender: Any) {
		setFlat()
		delegate?.updateIndex(for: flatPosition, with: selectedFlatIndex)
		window?.performClose(nil)
	}
	
	@IBAction func updateFilter(_ sender: Any) {
		
		let searchString = searchField.stringValue
		
		if searchBarIsEmpty() {
			filteredFlats = doomData.doom1Flats
			collectionView.reloadData()
			selectFlat()
		} else {
			filteredFlats = doomData.doom1Flats.filter({( flat : Flat) -> Bool in
				return flat.name.lowercased().contains(searchString.lowercased())
			})
			collectionView.reloadData()
			selectFlat()
		}
	}
	
	
	@IBAction func filterButtonPressed(_ sender: NSButton) {
		
		searchField.stringValue = sender.title
		updateFilter(sender)
	}
	
	
	// ====================
	// MARK: - Search Field
	// ====================
	
	func searchBarIsEmpty() -> Bool {

		return searchField.stringValue.isEmpty
	}

	

    
}
