//
//  PanelViewController+Resize.swift
//  PanelKit
//
//  Created by Louis D'hauwe on 08/10/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

extension PanelViewController {
	
	private var canResize: Bool {
		
		guard let contentDelegate = contentDelegate else {
			return false
		}
		
		let preferredSize = contentDelegate.preferredPanelContentSize
		let minSize = contentDelegate.minimumPanelContentSize
		let maxSize = contentDelegate.maximumPanelContentSize

		
		if preferredSize == minSize && preferredSize == maxSize {
			return false
		}
		
		return true
	}
	
	func showResizeHandleIfNeeded(animated: Bool = true) {
		
		guard canResize else {
			return
		}
		
		func show() {
			
			self.resizeCornerHandle.transform = .identity

		}
		
		self.resizeCornerHandle.alpha = 1

		if animated {
	
			UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: {
				
				self.resizeCornerHandle.transform = .identity

			}, completion: nil)
			
		} else {
			
			show()
		}
		
	}
	
	func hideResizeHandle(animated: Bool = true) {
		
		func hide() {
			
			var transform = CGAffineTransform.identity
			transform = transform.translatedBy(x: -44, y: -44)
			
			self.resizeCornerHandle.transform = transform
			self.resizeCornerHandle.alpha = 0
			
		}
		
		if animated {
			
			UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: {

				hide()

			}, completion: nil)
			
		} else {
			
			hide()
		}
		
	}
	
	func configureResizeHandle() {
		
		let resizeHandle = resizeCornerHandle
		resizeHandle.backgroundColor = .clear
		resizeHandle.translatesAutoresizingMaskIntoConstraints = false
		
		resizeHandle.tintColor = .white
		resizeHandle.transform = CGAffineTransform(rotationAngle: .pi/2 * 2)
		
		let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragCornerHandle(_:)))
		resizeHandle.addGestureRecognizer(recognizer)
		
		let resizeHandleTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didTapCornerHandle(_ :)))
		resizeHandleTapGestureRecognizer.minimumPressDuration = 0
		resizeHandleTapGestureRecognizer.delegate = self
		
		resizeHandle.addGestureRecognizer(resizeHandleTapGestureRecognizer)
		
		cornerHandleDidBecomeInactive(animated: false)
		hideResizeHandle(animated: false)
		
	}
	
	private func cornerHandleDidBecomeActive() {
		
		resizeCornerHandle.cornerHandleDidBecomeActive()
		
	}
	
	private func cornerHandleDidBecomeInactive(animated: Bool = true) {
		
		resizeCornerHandle.cornerHandleDidBecomeInactive(animated: animated)
		
	}
	
	@objc private func didTapCornerHandle(_ recognizer: UILongPressGestureRecognizer) {
		
		if recognizer.state == .began {
			
			cornerHandleDidBecomeActive()
			
		} else if recognizer.state == .failed || recognizer.state == .ended {
			
			cornerHandleDidBecomeInactive()
			
		}
		
	}
	
	@objc private func didDragCornerHandle(_ recognizer: UIPanGestureRecognizer) {
		
		guard let contentDelegate = contentDelegate else {
			return
		}
		
		guard let viewToMove = self.view else {
			return
		}
		
		if recognizer.state == .began {
			
			cornerHandleDidBecomeActive()
			
			startFrame = viewToMove.frame
			startDragPosition = recognizer.location(in: self.view)
			
		} else if recognizer.state == .changed, let startDragPosition = startDragPosition, let startFrame = startFrame {
			
			let newPosition = recognizer.location(in: self.view)
			
			var newFrame = startFrame
			
			let proposedWidth = newFrame.size.width + (newPosition.x - startDragPosition.x)
			let proposedHeight = newFrame.size.height + (newPosition.y - startDragPosition.y)
			
			let maxWidth = contentDelegate.maximumPanelContentSize.width
			let minWidth = contentDelegate.minimumPanelContentSize.width
			
			let maxHeight = contentDelegate.maximumPanelContentSize.height
			let minHeight = contentDelegate.minimumPanelContentSize.height
			
			let newWidth: CGFloat
			
			if proposedWidth > maxWidth {
				newWidth = maxWidth
			} else if proposedWidth < minWidth {
				newWidth = minWidth
			} else {
				newWidth = proposedWidth
			}
			
			let newHeight: CGFloat
			
			if proposedHeight > maxHeight {
				newHeight = maxHeight
			} else if proposedHeight < minHeight {
				newHeight = minHeight
			} else {
				newHeight = proposedHeight
			}
			
			newFrame.size.width = newWidth
			newFrame.size.height = newHeight
			
			self.manager?.updateFrame(for: self, to: newFrame)
			
		} else if recognizer.state == .ended {
			
			cornerHandleDidBecomeInactive()
			
		}
		
	}

}
