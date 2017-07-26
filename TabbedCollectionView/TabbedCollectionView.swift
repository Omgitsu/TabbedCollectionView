//
//  TabbedCollectionView.swift
//  TabbedCollectionView
//
//  Created by Guilherme Moura on 12/1/15.
//  Copyright © 2015 Reefactor, Inc. All rights reserved.
//

import UIKit

public protocol TabbedCollectionViewDataSource: class {
    func collectionView(_ collectionView: TabbedCollectionView, numberOfItemsInTab tab: Int) -> Int
    func collectionView(_ collectionView: TabbedCollectionView, titleForItemAtIndexPath indexPath: IndexPath) -> String
    func collectionView(_ collectionView: TabbedCollectionView, imageForItemAtIndexPath indexPath: IndexPath) -> UIImage
    func collectionView(_ collectionView: TabbedCollectionView, colorForItemAtIndexPath indexPath: IndexPath) -> UIColor
    func collectionView(_ collectionView: TabbedCollectionView, titleColorForItemAtIndexPath indexPath: IndexPath) -> UIColor
    func collectionView(_ collectionView: TabbedCollectionView, backgroundColorForItemAtIndexPath indexPath: IndexPath) -> UIColor
}

public protocol TabbedCollectionViewDelegate: class {
    func collectionView(_ collectionView: TabbedCollectionView, didSelectItemAtIndex index: Int, forTab tab: Int)
}

@IBDesignable open class TabbedCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var view: UIView!
    fileprivate let tabWidth = 80.0
    fileprivate let tabHeight = 32.0
    fileprivate var tabsInfo = [ItemInfo]()
    fileprivate var buttonTagOffset = 4827
    fileprivate var selectedTab = 0
    fileprivate var currentPage = 0
    fileprivate var cellWidth: CGFloat {
        return collectionView.frame.width / 5.0
    }
    fileprivate var cellHeight: CGFloat {
        return collectionView.frame.height / 3.0
    }
    fileprivate var userInteracted = false
    fileprivate var storedOffset = CGPoint.zero
    
    @IBOutlet weak var tabsScrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    open weak var dataSource: TabbedCollectionViewDataSource?
    open weak var delegate: TabbedCollectionViewDelegate?
    open var selectionColor = UIColor(red:0.9, green:0.36, blue:0.13, alpha:1.0) {
        didSet {
            reloadTabs()
        }
    }
    open var tabTitleColor = UIColor.darkText {
        didSet {
            reloadTabs()
        }
    }
    open var tabBackgroundColor = UIColor(white: 0.95, alpha: 1.0) {
        didSet {
            reloadTabs()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    open func createTabs(_ items: [ItemInfo]) {
        tabsInfo = items
        reloadTabs()
    }
    
    open func updateLayout() {
        let layout = HorizontalFlowLayout()
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - Private functions
    fileprivate func loadXib() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        setupCollectionView()
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TabbedCollectionView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    fileprivate func setupCollectionView() {
        let bundle = Bundle(for: type(of: self))
        collectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: "ItemCell")
        collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: "ItemCell")
        updateLayout()
        storedOffset = collectionView.contentOffset
    }
    
    fileprivate func reloadTabs() {
        let _ = tabsScrollView.subviews.map { $0.removeFromSuperview() }
        var i = 0
        for item in tabsInfo {
            let button = TabButton(title: item.title, image: item.image, color: item.color)
            button.selectionColor = selectionColor
            button.titleColor = tabTitleColor
            button.bgColor = tabBackgroundColor
            button.frame = CGRect(x: (tabWidth * Double(i)), y: 0, width: tabWidth, height: tabHeight)
            button.tag = i + buttonTagOffset
            button.addTarget(self, action: #selector(TabbedCollectionView.tabSelected(_:)), for: .touchUpInside)
            if i == selectedTab {
                button.isSelected = true
            }
            tabsScrollView.addSubview(button)
            i += 1
        }
        tabsScrollView.contentSize = CGSize(width: Double(i)*tabWidth, height: tabHeight)
    }
    
    func tabSelected(_ sender: UIButton) {
        // Deselect previous tab
        if let previousSelected = tabsScrollView.viewWithTag(selectedTab + buttonTagOffset) as? UIButton {
            previousSelected.isSelected = false
        }
        // Select current tab
        sender.isSelected = true
        selectedTab = sender.tag - buttonTagOffset
        
        // Updated collection view
        collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: true)
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionView data source methods
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numItems = dataSource?.collectionView(self, numberOfItemsInTab: selectedTab) else {
            return 0
        }
        return numItems
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
        cell.selectionColor = selectionColor
        cell.textLabel.text = dataSource?.collectionView(self, titleForItemAtIndexPath: indexPath)
        cell.imageView.image = dataSource?.collectionView(self, imageForItemAtIndexPath: indexPath)
        cell.imageView.tintColor = dataSource?.collectionView(self, colorForItemAtIndexPath: indexPath)
        cell.textLabel.textColor = dataSource?.collectionView(self, titleColorForItemAtIndexPath: indexPath)
        cell.contentView.backgroundColor = dataSource?.collectionView(self, backgroundColorForItemAtIndexPath: indexPath)
        return cell
    }
    
    // MARK: - UICollectionView delegate methods
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.collectionView(self, didSelectItemAtIndex: indexPath.row, forTab: selectedTab)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userInteracted = true
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            userInteracted = false
            storedOffset = collectionView.contentOffset
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        userInteracted = false
        storedOffset = collectionView.contentOffset
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !userInteracted {
            collectionView.contentOffset = storedOffset
        }
    }
}
