//
//  ContentView.swift
//  LexicalAnalysis_ios
//
//  Created by Layer on 2019/11/11.
//  Copyright © 2019 Layer. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var inRegex: String = ""
    @State var inString: String = ""
    @State var DFAshow = [""]
    @State var DFATable: [(String,[(Character,String)])]=[]
    
    @State var colNum: Int = 0
    @State var colName: [Character] = []
    
    @State var myLA: MyLexicalAnalysis = MyLexicalAnalysis()
    
    var body: some View {
        VStack{
            Spacer()
            Text("A lexical analysis tool.")
                .font(.title)
                .fontWeight(.thin)
                .fontWeight(Font.Weight.heavy)
        
            Text("Enter the regular expression to get the DFA.")
                .font(.body)
                .fontWeight(.light)
            
            Text("Input string to determine if it conforms to DFA")
                .font(.body)
                .fontWeight(.light)
            
            Spacer()
            
            VStack{
                HStack{
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("Regex:")
                        .font(.body)
                        .fontWeight(.light)
                    
                    TextField("Enter the regex here", text: $inRegex){
                        print(self.inRegex)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("String:")
                        .font(.body)
                        .fontWeight(.light)
                    
                    TextField("Enter the string here", text: $inString){
                        print(self.inRegex)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Button(action: {
                        print(self.inRegex)
                        self.DFAshow.append("Regex: " + self.inRegex)
                        //let myLA: MyLexicalAnalysis = MyLexicalAnalysis(str: self.inRegex)
                        self.myLA.setRegex(str: self.inRegex)
                        self.myLA.LexicalDeal()
                        self.myLA.BlankNodeDeal()
                        self.myLA.NFAtoDFA()
                        self.myLA.CreateDFATable()
                        self.DFATable = self.myLA.DFATable
                        for i in 0..<self.DFATable.count{
                            print(self.DFATable[i])
                        }
                        
                        for i in 0..<self.DFATable.count{//获取列名
                            var temp: [(Character,String)]
                            (_,temp) = self.DFATable[i]
                            for j in 0..<temp.count{
                                var ch: Character
                                (ch,_) = temp[j]
                                if(!self.colName.contains(ch)){
                                    self.colName.append(ch)
                                }
                            }
                        }
                        
                        var colLine: String = "       "
                        for z in 0..<self.colName.count{
                            print(self.colName[z])
                            colLine += "               " + String(self.colName[z])
                        }
                        
                        self.DFAshow.append(colLine)
                        
                       
                        for i in 0..<self.DFATable.count{
                            colLine = ""
                            var mianState:String
                            var temp: [(Character,String)]
                            (mianState,temp) = self.DFATable[i]
                            colLine += mianState
                            for j in 0..<self.colName.count{
                                colLine += "               "
                                var flag: Bool = false
                                for x in 0..<temp.count{
                                        var ch: Character
                                        var mainCol: String
                                        (ch,mainCol) = temp[x]
                                    
                                        if(ch == self.colName[j]){
                                            flag = true
                                            if(mainCol.count == 1){
                                                colLine += "  " + mainCol
                                            }
                                            else if (mainCol.count == 2){
                                                colLine += " " + mainCol
                                            }
                                            else{
                                                colLine += mainCol
                                            }
                                            break
                                        }
                                }
                                if(flag == false){
                                    colLine += "     "
                                }
                                
                            }
                            self.DFAshow.append(colLine)
                        }
                        self.DFAshow.append("结束状态为： "+self.myLA.FindEndNode())
                    }) {
                        Text("Regex OK")
                    }
                    Spacer()
                    Button(action: {
                        print(self.inString)
                        if(self.myLA.StringLexical(str: self.inString)){
                            self.DFAshow.append(self.inString+" belongs to the DFA!")
                        }
                        else{
                            self.DFAshow.append(self.inString+" does't belong to the DFA!")
                        }
                        
                    }) {
                        Text("String OK")
                    }
                    Spacer()
                    Button(action: {
                        self.inRegex = ""
                        self.inString = ""
                        self.DFAshow = [""]
                        self.myLA = MyLexicalAnalysis()
                    }) {
                        Text("Clear")
                    }
                    Spacer()
                }

            }
            Spacer()
            Spacer()
            
            VStack{
                List{
                    ForEach(DFAshow, id:\.self){ row in
                            Text(row)
                    }
                }
            }
           
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
