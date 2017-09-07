//
//  LMC_Interpreter.swift
//  LMC
//
//  Created by Salman Husain on 9/6/17.
//  Copyright © 2017 Salman Husain. All rights reserved.
//

import Foundation
struct DecimalInstruction {
    let instruction:Int
    let address:Int
}

class LMC:NSObject {
    var memory = [Int](repeating: 0, count: 100)
    var acc:Int = 0
    var programCounter:Int = 0
	//Our default print method
	var printBlock:((Any)->Void) = {
		toPrint in
		print(toPrint)
	}
	
    
    /// Parse asm into decimal code
    ///
    /// - Parameter fromString: The program
    func assembleProgramIntoMemory(fromString:String) {
		
		var program = parseASMInto2DArray(fromString: fromString)
		//Perform our first pass (find all label definitions and build a symbol table)
		var symbols:[String:Int] = [:]
		//We have to go by index so later we know which line to reference
		for lineIndex in 0..<program.count {
			var line = program[lineIndex]
			//If the line has three parts there must be a label at index 0
			if line.count == 3 || (line.count == 2 && (line[1] == "HLT" || line[1] == "INP" || line[1] == "OUT")) {
				symbols[line[0]] = lineIndex
				//Remove the label since it's already been processed out
				line.remove(at: 0)
				//We have to update the parent
				program[lineIndex] = line
			}
		}
		
		//Now go through all of the instructions and resolve the symbols
		for lineIndex in 0..<program.count {
			var line = program[lineIndex]
			for instructionIndex in 0..<line.count {
				let instruction = line[instructionIndex]
				//Try and resolve the symbol
				if let newLineNumber = symbols[instruction] {
					//hit! Replace it.
					line[instructionIndex] = "\(newLineNumber)"
					program[lineIndex] = line
				}
			}
		}
		
		//Now we need to parse each line into a decimal instruction
		var decimalProgram:[Int] = []
		for line in program {
			// smash the line together (i.e. [LDA,02] ->'LDA02')
			let instruction:String = line[0]
			var compiled = instruction
			
			//If we have two parts to the instruction there is a paramater address
			if line.count == 2  {
				if let address = Int(line[1]) {
					compiled += String.init(format: "%02d", address)
				}else {
					//If our second part exists but (the addr) is not parseable as an address it's an unresolved symbol
					dPrint("Line: \(line) failed to compile. Unresolvable symbol.")
					return
				}
			}
			
			//Now replace each ASCII instruction with the 100 code
			compiled = compiled.replacingOccurrences(of: "LDA", with: "5")
			compiled = compiled.replacingOccurrences(of: "STA", with: "3")
			compiled = compiled.replacingOccurrences(of: "ADD", with: "1")
			compiled = compiled.replacingOccurrences(of: "SUB", with: "2")
			compiled = compiled.replacingOccurrences(of: "INP", with: "901")
			compiled = compiled.replacingOccurrences(of: "OUT", with: "902")
			compiled = compiled.replacingOccurrences(of: "HLT", with: "000")
			compiled = compiled.replacingOccurrences(of: "BRA", with: "6")
			compiled = compiled.replacingOccurrences(of: "BRZ", with: "7")
			compiled = compiled.replacingOccurrences(of: "BRP", with: "8")
			compiled = compiled.replacingOccurrences(of: "DAT", with: "0")
			if let decimalInstruction = Int(compiled) {
				decimalProgram.append(decimalInstruction)
			}else {
				dPrint("Line: \(line) failed to compile.")
				return
			}
		}
		
		//If we made it here we compiled...
		loadProgramIntoMemory(fromDecimal: decimalProgram)
		
    }
	
	func parseASMInto2DArray(fromString:String) -> [[String]] {
		//Bad idea: DAT alone fills with 0 by default but that's bad for parsing.
		var fromString = fromString.uppercased().replacingOccurrences(of: "DAT\n", with: "DAT 0\n")
		//Parse in our instruction lines into a 2D array
		var program:[[String]] = []
		
		//Itterate by line
		for line in fromString.components(separatedBy: "\n") {
			//..and then by character in the line. This is done to extract labels properly
			var lineProgram:[String] = [] //buffer the program line for simplicity
			var currentLineBuffer = "" //we have to buffer the line because we have no where to add it until it is terminated.
			for character in line {
				//a space terminates our instruction, so we would copy it to the line program here
				if character == " " || character == "\t" {
					//we want to make sure we aren't empty (i.e. repeated spaces/tabs)
					if currentLineBuffer.isEmpty == false {
						lineProgram.append(currentLineBuffer)
						currentLineBuffer = ""
					}
				}
				// These are comment chars and so we should stop reading at them
				else if character == "/" || character == ";" {
					break
				}
				else {
					//We have an instruction char, add it to the buffer
					currentLineBuffer += "\(character)"
				}
			}
			
			//We've gone through all the chars, now we need to manually add the last buffer it exists since we have split by lines (i.e. the third terminator)
			if currentLineBuffer.isEmpty == false {
				lineProgram.append(currentLineBuffer)
			}
			//now add our line to the main storage
			program.append(lineProgram)
			
		}
		return program
	}
    
    func loadProgramIntoMemory(fromDecimal:[Int]) {
		//Stuff the bytes(??) into our memory map
        for i in 0..<fromDecimal.count {
            memory[i] = fromDecimal[i]
        }
        dPrint("LOADED \(fromDecimal.count) instructions")
    }
    
    
    /// Parse an instruction number (ie 192) into the instruction code 1 with the address 92 using the DecimalInstruction struct
    ///
    /// - Parameter instruction: The instruction to parse
    func parseDecimalInstruction(instruction:Int) -> DecimalInstruction {
        let instructionCode:Int = instruction/100
        let address:Int = instruction % 100 //All instructions are divisible by 100 (9xx, 2xx, etc) so we can grab the address target by modulo.
        
        return DecimalInstruction(instruction: instructionCode, address: address)
    }
    
    /// Execute a program from memory
    func execute() {
        var shouldHalt = false
        
        while !shouldHalt {
            //Parse the current program container instruction into a nice container so we can easily access the instruction and address value
            let instruction = parseDecimalInstruction(instruction: memory[programCounter])
            // Now let's execute said instruciton.
            // First check for HLT (000)
            if instruction.instruction == 0 {
                dPrint("[\(programCounter)] HALT")
                shouldHalt = true
                break
            //Check for 1xx instruction (ADD: Add the contents of address xx to the accumulator.)
            }else if instruction.instruction == 1 {
                //Grab our content to add to ACC from mem
                let toAddValue = memory[instruction.address]
                //dPrint("[\(programCounter)] ADD ACC: \(acc) with new \(toAddValue). ACC now equals: \(acc + toAddValue)")

                acc += toAddValue
                
                //Increase our program counter since we aren't moving anywhere special
                programCounter += 1
            //Check for 2xx (Subtract the contents address xx from the accumulator.)
            }else if instruction.instruction == 2 {
                //Grab our content to sub to ACC from mem
                let toSubValue = memory[instruction.address]
                //dPrint("[\(programCounter)] SUB ACC: \(acc) with new \(toSubValue). ACC now equals: \(acc - toSubValue)")
                
                acc -= toSubValue
                
                //Increase our program counter since we aren't moving anywhere special
                programCounter += 1
            //Check for 3xx (Store the contents of the accumulator to address xx.)
            }else if instruction.instruction == 3 {
                //dPrint("[\(programCounter)] STA \(acc) into \(instruction.address)")
                //Set our memory address of our instruciton to acc, pretty easy.
                memory[instruction.address] = acc
                
                //Increase our program counter since we aren't moving anywhere special
                programCounter += 1
            //Check for 4xx (BAD INSTRUCTION???)
            }else if instruction.instruction == 4 {
                dPrint("[\(programCounter)] 4xx instruction is an undefined instruction, HALTING!!!")
                shouldHalt = true
                break
            //Check for 5xx (Load the contents of address xx onto the accumulator.)
            }else if instruction.instruction == 5 {
                //dPrint("[\(programCounter)] LDA")
                acc = memory[instruction.address]
                //Increase our program counter since we aren't moving anywhere special
                programCounter += 1
            //Check for 6xx (Set the program counter to address xx.)
            }else if instruction.instruction == 6 {
                //dPrint("[\(programCounter)] BRA: moving execution to \(instruction.address)")
                
                //We don't increment here, we jump to the new instruction
                programCounter = instruction.address
            //Check for 7xx (If the contents of the accumulator are ZERO , set the program counter to address xx.)
            }else if instruction.instruction == 7 {
                if acc == 0 {
                    //Branch condition met, jump.
                    //dPrint("[\(programCounter)] BRZ: moving execution to \(instruction.address)")
                    programCounter = instruction.address
                }else {
                    //We didn't meet the condition, continue
                    //dPrint("[\(programCounter)] BRZ: continue")
                    programCounter += 1
                }
            }
            //Check for 8xx (If the contents of the accumulator are ZERO or positive, set the program counter to address xx.)
            else if instruction.instruction == 8 {
                if acc >= 0 {
                    //Branch condition met, jump.
                    //dPrint("[\(programCounter)] BRP: moving execution to \(instruction.address)")
                    programCounter = instruction.address
                }else {
                    //We didn't meet the condition, continue
                    //dPrint("[\(programCounter)] BRP: continue")
                    programCounter += 1
                }
            }
            //Check for 9xx (I/O)
            else if instruction.instruction == 9 {
                //The address on IO calls sets the output destination. 
                //901 (Copy the value from the “in box” onto the accumulator.)
                if instruction.address == 1 {
                    dPrint("[\(programCounter)] 901: input is not currently supported, setting ACC to 0.Store data manually instead.")
                    acc = 0
                    
                }
                //902 (Copy the value from the accumulator to the “out box”.)
                else if instruction.address == 2 {
                    //dPrint("[\(programCounter)] 902: printing ACC")
                    dPrint("::>\(acc)")
                }else {
                    dPrint("[\(programCounter)] 9xx: I/O destination/source \(instruction.address) is not valid for LMC, HALTING!!!")
                    shouldHalt = true
                    break
                }
                
                //Increase our program counter since we aren't moving anywhere special
                programCounter += 1
            }
        }
    }
	
	func dPrint(_ string:Any) {
		printBlock(string)
	}
}

