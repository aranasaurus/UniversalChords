//
//  ViewController.swift
//  UniversalChords
//
//  Created by Chase Caster on 4/21/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit
import MusicKit


class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let chordLabel = UITextField()
    let notePicker = UIPickerView()
    
    let diagram = ChordDiagramView()
    
    let instrumentLabel = UITextField()
    let instrumentPicker = UIPickerView()
    let qualityPicker = UISegmentedControl()
    
    var chromae: [Chroma] {
        return (0...11).map { i in
            Chroma(rawValue: i)!
        }
    }
    var chromaNames: [String] {
        return chromae.map { chroma in
            chroma.flatDescription
        }
    }
    
    let qualities: [ChordQuality] = [
        .Major,
        .Minor,
        .DominantSeventh,
        .Augmented,
        .Diminished,
        .MinorSeventh,
    ]
    var chord: PitchSet!
    
    let instruments = [
        Instrument(name:"Banjo", strings:[.D, .B, .D, .G]),
        Instrument(name:"Guitar", strings:[.E, .A, .D, .G, .B, .E]),
        Instrument(name:"Mandolin", strings:[.G, .D, .A, .E]),
        Instrument(name:"Ukulele", strings:[.G, .C, .E, .A]),
    ]
    var instrument: Instrument!
    
    let padding: CGFloat = 40
    let circleSize = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notePicker.delegate = self
        notePicker.dataSource = self
        notePicker.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(notePicker)
        
        for (i, quality) in enumerate(qualities) {
            qualityPicker.insertSegmentWithTitle(quality.symbol, atIndex: i, animated: false)
        }
        qualityPicker.selectedSegmentIndex = 0
        qualityPicker.setTranslatesAutoresizingMaskIntoConstraints(false)
        qualityPicker.tintColor = UIColor.blackColor()
        qualityPicker.addTarget(self, action: "chooseChord", forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(qualityPicker)
        
        chordLabel.font = chordLabel.font.fontWithSize(28)
        chordLabel.textAlignment = .Center
        notePicker.selectRow(chromae.count * circleSize, inComponent: 0, animated: false)
        self.chooseChord()
        view.addSubview(chordLabel)
        
        instrumentPicker.delegate = self
        instrumentPicker.dataSource = self
        
        instrumentLabel.inputView = instrumentPicker
        instrumentLabel.font = instrumentLabel.font.fontWithSize(18)
        instrumentLabel.textAlignment = .Center
        instrumentPicker.selectRow(1, inComponent: 0, animated: false)
        self.chooseInstrument()
        view.addSubview(instrumentLabel)
        
        view.addSubview(diagram)
        diagram.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        chordLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        diagram.setTranslatesAutoresizingMaskIntoConstraints(false)
        instrumentLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints([
            NSLayoutConstraint(item: notePicker, attribute: .Top,    relatedBy: .Equal, toItem: view, attribute: .Top,    multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: notePicker, attribute: .Right,  relatedBy: .Equal, toItem: view, attribute: .Right,  multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: notePicker, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: notePicker, attribute: .Width,  relatedBy: .Equal, toItem: nil,  attribute: .Width,  multiplier: 1.0, constant: 40.0),
            
            NSLayoutConstraint(item: diagram, attribute: .Top,    relatedBy: .Equal, toItem: chordLabel,      attribute: .Bottom, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: diagram, attribute: .Left,   relatedBy: .Equal, toItem: view,            attribute: .Left,  multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: diagram, attribute: .Right,  relatedBy: .Equal, toItem: notePicker,      attribute: .Left,  multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: diagram, attribute: .Bottom, relatedBy: .Equal, toItem: instrumentLabel, attribute: .Top,    multiplier: 1.0, constant: -10.0),
            
            NSLayoutConstraint(item: chordLabel, attribute: .Top,   relatedBy: .Equal, toItem: view,          attribute: .Top,   multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: chordLabel, attribute: .Right, relatedBy: .Equal, toItem: view,          attribute: .Right, multiplier: 1.0, constant: -10.0),
            
            NSLayoutConstraint(item: qualityPicker, attribute: .Top,   relatedBy: .Equal, toItem: view,       attribute: .Top,  multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: qualityPicker, attribute: .Left,  relatedBy: .Equal, toItem: view,       attribute: .Left, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: qualityPicker, attribute: .Right, relatedBy: .Equal, toItem: chordLabel, attribute: .Left, multiplier: 1.0, constant: -10.0),
            
            NSLayoutConstraint(item: instrumentLabel, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: instrumentLabel, attribute: .Width,  relatedBy: .Equal, toItem: view, attribute: .Width,  multiplier: 1.0, constant: 0.0),
        ])
    }
    
    func chooseChord() {
        let chromaIndex = notePicker.selectedRowInComponent(0)
        let chroma = chromae[chromaIndex % chromae.count]
        let qualityIndex = qualityPicker.selectedSegmentIndex
        let quality = qualities[qualityIndex]
        let chord = Harmony.create(quality.intervals)
        
        chordLabel.text = "\(chroma.flatDescription) \(quality.symbol)"
        chordLabel.resignFirstResponder()
        
        diagram.chord = chord(Pitch(chroma: chroma, octave: 1))
    }
    
    func chooseInstrument() {
        let index = instrumentPicker.selectedRowInComponent(0)
        instrument = instruments[index]
        instrumentLabel.text = instrument.name
        instrumentLabel.resignFirstResponder()
        
        diagram.instrument = instrument
    }
    
    func choices(picker:UIPickerView) -> [[String]] {
        switch picker {
        case notePicker:
            return [chromaNames]
        case instrumentPicker:
            return [instruments.map {i in i.name}]
        default:
            return [[]]
        }
    }
    
    // Mark: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return choices(pickerView).count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = choices(pickerView)[component].count
        if pickerView == notePicker && component == 0 {
            rows *= 2 * circleSize
        }
        return rows
    }
    
    // Mark: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let componentChoices = choices(pickerView)[component]
        return componentChoices[row % componentChoices.count]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == notePicker {
            chooseChord()
            let componentChoices = choices(pickerView)[component]
            pickerView.selectRow(row % componentChoices.count + circleSize * componentChoices.count, inComponent: component, animated: false)
        } else if pickerView == instrumentPicker {
            chooseInstrument()
        }
    }
}

