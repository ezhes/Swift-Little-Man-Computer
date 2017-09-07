//
//  ViewController.swift
//  LMC
//
//  Created by Salman Husain on 9/6/17.
//  Copyright © 2017 Salman Husain. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let machine = LMC()
        
        //Times table example for 12
        //machine.loadProgramIntoMemory(fromDecimal: [533, 326, 532, 327, 531, 328, 329, 528, 126, 328, 529, 132, 329, 227, 716, 607, 528, 902, 527, 132, 327, 226, 704, 825, 604, 000, 000, 000, 000, 000, 000, 000, 001, 012, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000])
        machine.assembleProgramIntoMemory(fromString: "        LDA FAKEINP\n        STA VALUE\n        LDA ONE\n        STA MULT\nOUTER   LDA ZERO\n        STA SUM\n        STA TIMES\nINNER   LDA SUM\n        ADD VALUE\n        STA SUM\n        LDA TIMES\n        ADD ONE\n        STA TIMES\n        SUB MULT\n        BRZ NEXT\n        BRA INNER\nNEXT    LDA SUM\n        OUT\n        LDA MULT\n        ADD ONE\n        STA MULT\n        SUB VALUE\n        BRZ OUTER\n        BRP DONE\n        BRA OUTER\nDONE    HLT\nVALUE   DAT 0 // Times table for\nMULT    DAT 0 // one input number\nSUM     DAT\nTIMES   DAT\nCOUNT   DAT\nZERO    DAT 000\nONE     DAT 001\nFAKEINP DAT 012")
        machine.execute()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

