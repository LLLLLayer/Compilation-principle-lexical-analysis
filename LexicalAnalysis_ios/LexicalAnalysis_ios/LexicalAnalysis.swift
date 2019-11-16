//
//  MyLexicalAnalysis.swift
//  LexicalAnalysis
//
//  Created by Layer on 2019/11/6.
//  Copyright © 2019 Layer. All rights reserved.
//

import Foundation

class Node{//状态接收的h输入类
    var key: Character//该状态转移接收的输入值；
    var isBegin: Bool = false//标记是否是开始状态进行的接收
    var isEnd: Bool = false//标记是否为达到结束结束进行的接收
    var list: [Node]//当前接收达到的状态，该状态可接收的输入
    var isManaged: Bool = false//标记进行空输入的移除时对Node是否经过了处理
    var isFinded: Bool = false//在去空节点时候寻找非空节点时是否被访问过
    var stateNum: [String] = []//对每个状态进行的编号
    
    init(){//构造函数，初始该对象
        self.isBegin = false
        self.isEnd = false
        self.key = " "
        self.list = []
    }
    
    func copyNode(newNode: Node){//象拷贝，将newNode复制给本Node对象
        self.isBegin = newNode.isBegin
        self.isEnd = newNode.isEnd
        self.key = newNode.key
        self.list = newNode.list
        self.stateNum = newNode.stateNum
    }
}

class MyLexicalAnalysis{//词法分析类
    var regex: String = ""//正则表达式，需要处理的字符串
    var isWrong: Bool = false//检查正则表达式正误
    var charStuck: [(Node,Node)] = []//在将正则式转换为ε-NFA时使用的存放最初输入和最后输入的输入值栈
    var markStuck: [(Character,Int)] = []//在将正则式转换为ε-NFA时使用的存放符号（包括“（”、“）”、“｜”、“*”）和该符号所在正则式字符串的位置的符号栈
    var beginNodeNFA: Node = Node()//NFA的开始
    var beginNodeDFA: Node = Node()//DFA的开始
    var DFATable: [(String,[(Character,String)])] = []  //最后生成的DFA表
    var stateEnd = ""//DFA表中是结束状态的编号
    
    //构造函数
    init(){
        beginNodeNFA.isBegin = true
    }
    
    func setRegex(str:String){
        self.regex = str
    }
    
    init(str: String){
        self.regex = str
        beginNodeNFA.isBegin = true
    }
    
    //遍历正则式字符串进行数据处理
    func LexicalDeal(){
        for i in 0..<regex.count{
            //正则表达式错误
            if(isWrong){
                return
            }
            let temp = regex[regex.index(regex.startIndex, offsetBy: i)]//当前字符
            //print(temp)
            //符号处理
            if(temp == "("){
                LeftBracketDeal()
            }
            else if(temp == ")"){
                RightBracketDeal(i: i)
            }
            else if(temp == "|"){
                OrDeal(i: i)
            }
            else if(temp == "*"){
                AnyDeal(i: i)
            }
            //字母处理
            else{
                //将字母放入字符栈中
                let aNode = Node()
                let bNode = Node()
                aNode.key = temp
                aNode.list.append(bNode)
                self.charStuck.append((aNode,bNode))
            }
        }
        //拼接所有字符栈中的结果，初始的NFA
        var strA:Node
        var strB:Node
        (strA,strB)=self.charStuck.popLast()!
        strB.isEnd=true
        //遍历字符栈拼接所有字符
        while (self.charStuck.count>0){
            var aNode:Node
            var bNode:Node
            (aNode,bNode)=self.charStuck.popLast()!
            bNode.list.append(strA)
            strA=aNode
        }
        if (strA.key == " "){
            strA.isBegin=true
            beginNodeNFA=strA
        }
        else{
            beginNodeNFA=Node()
            beginNodeNFA.isBegin=true
            beginNodeNFA.list.append(strA)
        }
    }
    
    func LeftBracketDeal(){//处理")"
        self.markStuck.append(("(", self.charStuck.count))//当前charStuck有多少字符
    }
    
    func RightBracketDeal(i: Int){//处理")"
        var x:Int=0
        (_,x)=self.markStuck.last!
        if(x != self.charStuck.count + 1){
            while(x<self.charStuck.count - 1){//之前可链接的状态链接
                var aNode = Node()
                var bNode = Node()
                (aNode,bNode)=self.charStuck.popLast()!
                var cNode = Node()
                var dNode = Node()
                (cNode,dNode)=self.charStuck.popLast()!
                dNode.list.append(aNode)
                self.charStuck.append((cNode,bNode))
            }
        }
        //再加头尾空状态
        var RecentMark:Character
        let aNode:Node=Node()//新建起始节点
        let bNode:Node=Node()//新建结束节点
        var strA:Node
        var strB:Node
        (strA,strB)=self.charStuck.popLast()!
        aNode.list.append(strA)
        strB.list.append(bNode)
        repeat{
            if (self.markStuck.count == 0){//找不到左括号
                isWrong=true
                break
            }
            (RecentMark,_)=self.markStuck.popLast()!
            if (RecentMark == "|"){//括号中的或运算
                (strA,strB)=self.charStuck.popLast()!
                aNode.list.append(strA)
                strB.list.append(bNode)
            }
            else{//遇到了左括号
                break
            }
        }while(1==1)
        self.charStuck.append((aNode,bNode))
    }

    func OrDeal(i:Int){//处理"|"
        if (self.charStuck.count>0){
            var x:Int=0
            if(markStuck.count == 0){
                x=0
            }
            else{
                (_,x)=self.markStuck.last!
            }
            if (x != self.charStuck.count + 1){
                while (x<self.charStuck.count - 1){
                    var aNode: Node
                    var bNode: Node
                    (aNode,bNode)=self.charStuck.popLast()!
                    var cNode: Node
                    var dNode: Node
                    (cNode,dNode)=self.charStuck.popLast()!
                    dNode.list.append(aNode)
                    self.charStuck.append((cNode,bNode))
                }
            }
        }
        self.markStuck.append(("|",self.charStuck.count))
    }
    
    func AnyDeal(i:Int){//处理"*"
        let aNode:Node=Node()
        var strA:Node
        var strB:Node
        (strA,strB)=self.charStuck.popLast()!
        aNode.list.append(strA)
        strB.list.append(aNode)
        self.charStuck.append((aNode,aNode))
    }
    
    
    func BlankNodeDeal(){  //处理空节点
        var tNode=beginNodeNFA
        RemoveBlankNode(tNode: &tNode)
        beginNodeNFA.stateNum.append("0")
        var x: Int = 1
        marknode(k: &x, tNode: beginNodeNFA)
    }
    
    func RemoveBlankNode(tNode: inout Node){
        if (tNode.isManaged == false){
            tNode.isManaged = true
            var NewList: [Node] = []
            NewList.append(tNode)
            FindNewList(NewList: &NewList, tnode: tNode)
            NewList.remove(at: 0)
            tNode.list = NewList
            for i in 0..<tNode.list.count{
                RemoveBlankNode(tNode: &tNode.list[i])
            }
        }
    }
    
    func FindNewList(NewList:inout [Node],tnode: Node){
        for i in 0..<tnode.list.count{
            if (tnode.list[i].key != " "){
                NewList.append(tnode.list[i])
            }
            else{
                if (tnode.list[i].isEnd == true){
                    NewList[0].isEnd=true
                }
                if (tnode.list[i].isFinded == false) {//处理遗漏情况
                    tnode.list[i].isFinded=true
                    FindNewList(NewList: &NewList, tnode: tnode.list[i])
                    tnode.list[i].isFinded=false
                }
            }
        }
    }
    
    func marknode(k: inout Int,tNode:Node){//编号处理
        for i in 0..<tNode.list.count{
            if (tNode.list[i].stateNum.count == 0){
                tNode.list[i].stateNum.append(String(k))
                k=k+1
                marknode(k: &k, tNode: tNode.list[i])
            }
        }
    }

    func NFAtoDFA(){
        var QueueState: [Node]=[]
        var SetState: [Node]=[]
        var charSet: [Character]=[]
        var pNode: Node
        var DFApnode: Node
        var isExist: Bool = false

        //DFA头节点初始化
        beginNodeDFA.copyNode(newNode: beginNodeNFA)
        beginNodeDFA.list = []
        QueueState.append(beginNodeNFA)
        SetState.append(beginNodeDFA)
        DFApnode = beginNodeDFA

        while (QueueState.count>0){
            pNode=QueueState[0]//.
            QueueState.remove(at: 0)
            charSet.removeAll()

            for i in 0..<pNode.list.count {//找相连的字符集合
                if !charSet.contains(pNode.list[i].key){
                    charSet.append(pNode.list[i].key)
                }
            }

            for ch in charSet{
                var newNode = Node()
                newNode.key = ch
                //遍历相连节点，对字符相同的线进行合并节点
                for i in 0..<pNode.list.count{
                    if pNode.list[i].key == ch{
                        if pNode.list[i].isBegin{
                            newNode.isBegin=true
                        }
                        if (pNode.list[i].isEnd){
                            newNode.isEnd=true
                        }
                        //将要合成同一个节点的编号加入当前的newnode中
                        for k in pNode.list[i].stateNum{
                            if (newNode.stateNum.contains(k) == false){
                                newNode.stateNum.append(k)
                            }
                        }
                        //相连节点加入
                        for k in pNode.list[i].list{
                            isExist=false
                            for x in newNode.list{
                                if (x.stateNum == k.stateNum){
                                    isExist=true
                                }
                            }
                            if isExist==false{
                                newNode.list.append(k)
                            }
                        }
                    }
                }
                newNode.stateNum.sort()
                isExist = false
                for Lnode in SetState{
                    if Lnode.stateNum == pNode.stateNum{
                        DFApnode=Lnode
                    }
                }
                for Dnode in SetState{
                    if Dnode.stateNum == newNode.stateNum{
                        isExist=true
                        DFApnode.list.append(Dnode)
                    }
                }
                if (isExist == false){
                    let anewnode=Node()
                    anewnode.copyNode(newNode: newNode)
                    anewnode.list=[]
                    DFApnode.list.append(anewnode)
                    SetState.append(anewnode)
                    QueueState.append(newNode)
                }
                else{
                    isExist=false
                }
                newNode=Node()
            }
        }
    }

    //寻找结束节点的标号
    func FindEndNode()->String{
        self.FindEndNode(tnode: beginNodeDFA)
        return self.stateEnd
    }
    
    func FindEndNode(tnode:Node){
        tnode.isManaged=false //标记是否被遍历过
        if (tnode.isEnd){
            if (self.stateEnd.count>0){
                var Name:String=""
                for s in tnode.stateNum{
                    Name=Name+s
                }
                self.stateEnd=self.stateEnd+","+Name
            }
            else{
                var Name:String=""
                for s in tnode.stateNum{
                    Name=Name+s
                }
                self.stateEnd=Name
            }
        }
        for i in tnode.list{
            if i.isManaged{
                FindEndNode(tnode: i)
            }
        }
    }
    
    func CreateDFATable(){
        CreateDFATable(tnode: self.beginNodeDFA)
    }
    
    func CreateDFATable(tnode:Node){
        tnode.isManaged=true//标记是否被遍历过
        var NodeName=""
        for s in tnode.stateNum{
            NodeName=NodeName+s
        }
        var nextlist:[(Character,String)]=[]
        for next in tnode.list{
            var nextName:String=""
            for s in next.stateNum{
                nextName=nextName+s
            }
            nextlist.append((next.key,nextName))
        }
        self.DFATable.append((NodeName,nextlist))
        for next in tnode.list{
            if next.isManaged == false{
                CreateDFATable(tnode: next)
            }
        }
    }
    
    func StringLexical(str:String)->Bool{
        var DFAnode:Node=beginNodeDFA
        var findNode:Bool=false
        for ch in str{
            findNode=false
            for i in 0..<DFAnode.list.count{
                if (ch == DFAnode.list[i].key){
                    findNode=true
                    //print(DFAnode.list[i].s)
                    DFAnode=DFAnode.list[i]
                    break
                }
            }
            if (findNode == false){
                return false
            }
        }
        if DFAnode.isEnd == true{
            return true
        }
        else{
            return false
        }
    }
}
