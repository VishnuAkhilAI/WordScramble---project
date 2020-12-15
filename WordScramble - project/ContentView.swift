//
//  ContentView.swift
//  WordScramble - project
//
//  Created by Vishnu akhil Upparapalle on 15/12/20.
//  Copyright © 2020 Vishnu akhil Upparapalle. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var newWord = ""
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    
    // Alert properties
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView{
                    VStack{
                        TextField("Enter a word", text: $newWord, onCommit: addNewWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                            List(usedWords,id:\.self){
                                        Image(systemName: "\($0.count).circle")
                                        Text($0)
                            }
                        Text("Current Score : \(usedWords.count)")
                    }
        .navigationBarTitle(rootWord)
        .onAppear(perform: startGame)
        .alert(isPresented: $showingAlert){ Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK"))) }
        .navigationBarItems(trailing: Button("New Game"){self.startGame()})
        }
    }
    func addNewWord(){
        // Lowering casing the entered word and removing whitespaces ad newlines
        let enteredWord = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // Checking if it has atleast 1 word else exit!
        guard enteredWord.count > 0 else{
            return
        }
        // Check is the word is origial, possible and real
        guard isOrigitnal(word: enteredWord) else {
            alertWordError(title: "Word used already", message: "Enter a new word!")
            return
        }
        
        guard isPossible(word: enteredWord) else {
            alertWordError(title: "Word not possible", message: "You need to create the words from the root word")
            return
        }
        
        guard isReal(word: enteredWord) else {
            alertWordError(title: "Word not valid", message: "Ener a valid english word")
            return
        }
        
         guard challangeMethod(word: enteredWord) else {
            alertWordError(title: "Word Length", message: "Enter words more than 3")
            return
        }
        // Inseting the word in usedWord array at postion 0
        usedWords.insert(enteredWord, at: 0)
        // Setting the textfield to empty i.e newWord to empty string
        newWord = ""
        
    }
    
    func startGame(){
        // Find the URL to find the start.txt in out bundle
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordURL){
                // Spilt the string into an array of strings, spilting on linebreaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // Pick a random word or use "CRASHED" as a default
                rootWord = allWords.randomElement() ?? "CRASHED"
                // Empty the array when ever you start ew game
                usedWords = [String]()
                // everything worked, so exit
                return
            }
        }
        // if there is a fatal error in out app we need it to crash and report an error
        fatalError("Could not load start.txt from bundle")
    }
    // Method to check if the word is possible from the rootword (i.e APPLE from CRASHED)
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord
        
        for letter in word{
            // Get the postion of the letter in the tempWord
            if let position = tempWord.firstIndex(of: letter){
                // Remove the charecter at the postion
                tempWord.remove(at: position)
            }else{
                return false
            }
        }
        return true
    }
    // Method to check if the word is already used
    func isOrigitnal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    // Check if the word is a valid English charecter
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range  = NSRange(location: 0, length: word.utf16.count)
        let misspelledWord = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledWord.location == NSNotFound
    }
    // Method to set title and message based on the parameters it recives
    func alertWordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingAlert = true
    }
    
    func challangeMethod(word: String) -> Bool {
        return word.count > 3 ? true : false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
