//
//  main.swift
//  pokerGame
//
//  Created by John Demirci on 12/11/19.
//  Copyright © 2019 John Demirci. All rights reserved.


//



/*
 TODO
    -> get rid of some of the unnecessary eval callings
    -> workon the compare function so that having a draw is not a pssibility
 */




import Foundation
enum score: Int {
    case High_Card = 0, Pair, Two_Pairs, Three_of_a_Kind, Straight, Flush, Full_House, Four_of_a_Kind, Straight_Flush
}
struct cards {
    var SUIT: String
    var FACE: String
}
struct hands {
    var theCards = [cards]()
    var myScore: score
}
func createDeck () -> [cards] {
    var TempDeck = [cards]()
    let suits = ["DIAMOND", "SPADES", "CLUBS", "HEART"]
    var counter = 1 // faces
    for i in 0..<52 {
        if counter > 13 {
            counter = 1
        }
        TempDeck.append(.init(SUIT: suits[i % 4], FACE: String(counter)))
        counter = counter + 1
    }
    return TempDeck
}

func main () {
    // var deck = [cards]()
    // creating an array of a sfized size
    var deck = createDeck()
    // printing out the deck
    for index in deck {
        print("\(index.FACE) of \(index.SUIT)")
    }
    let temp = [cards]()
    // [userHand, deck] = giveHand(deck: deck, hand: userHand)
    var userHand = hands(theCards: temp, myScore: score.High_Card)  // creating an array for the user holding 5 cards
    let x = giveHand(deck: deck, hand: userHand) // calling a function to give 5 cards to the user
    userHand.theCards = x[0] // x[0] contains the user's cards so we give the user the cards
    deck = x[1] // subtracting those cards from the dek replacing them with "empty"
    var compHand = hands(theCards: temp, myScore: score.High_Card)
    let y = giveHand(deck: deck, hand: compHand)
    compHand.theCards = y[0]
    deck = y[1]
    let aidec = AIdecision(myHand: compHand, myDeck: deck)
    compHand.theCards = aidec[0]
    deck = aidec[1]
    let usDec = userDecision(myHand: userHand, myDeck: deck)
    userHand.theCards = usDec[0]
    deck = usDec[1]
    userHand = evalHand(eval: userHand)
    compHand = evalHand(eval: compHand)
    compare(hand1: compHand, hand2: userHand)
}

func userDecision (myHand: hands, myDeck: [cards]) -> ([[cards]]) {
    var hand = myHand
    var deck = myDeck
    hand = evalHand(eval: hand)
    for i in hand.theCards {
        switch i.FACE {
        case "11":
            print("J of \(i.SUIT)")
            break
        case "12":
            print("Q of \(i.SUIT)")
            break
        case "13":
            print("K of \(i.SUIT)")
            break
        case "1":
            print("A of \(i.SUIT)")
            break
        default:
            print("\(i.FACE) of \(i.SUIT)")
        }
    }
    print("how many cards do you want to swap ?")
    let amountOfSwapCards: Int = Int(readLine()!)!
    print("please specify the card position one at a time")
    var position: Int
    for _ in 0..<amountOfSwapCards {
        position = Int(readLine()!)!
        let x = changeCard(theHand: hand, myDeck: deck, pos: position)
        hand.theCards = x[0]
        deck = x[1]
    }
    hand = evalHand(eval: hand)
    return [hand.theCards, deck]
}

func AIdecision (myHand: hands, myDeck: [cards]) -> ([[cards]]) {
    var hand: hands = myHand
    var deck = myDeck
    hand = evalHand(eval: hand)
    var pairLocation: Int = 0
    var diamondCount = 0
    var heartCount = 0
    var clubCount = 0
    var spadesCount = 0
    var threeOfAKing = [Int]()
    // if 4/5 the suits are the same
    // the the computer decides to draw one card
    for i in hand.theCards {
        if i.SUIT == "DIAMOND" {
            diamondCount = diamondCount + 1
        } else if i.SUIT == "HEART" {
            heartCount = heartCount + 1
        } else if i.SUIT == "CLUBS" {
            clubCount = clubCount + 1
        } else if i.SUIT == "SPADES" {
            spadesCount = spadesCount + 1
        }
    }
    if spadesCount == 4 {
        for i in 0..<5 {
            if hand.theCards[i].SUIT != "SPADES" {
                let x = changeCard(theHand: hand, myDeck: deck, pos: i)
                hand.theCards = x[0]
                deck = x[1]
            }
        }
        hand = evalHand(eval: hand)
        return [hand.theCards, deck]
    }
    if heartCount == 4 {
        for i in 0..<5 {
            if hand.theCards[i].SUIT != "HEART" {
                let x = changeCard(theHand: hand, myDeck: deck, pos: i)
                hand.theCards = x[0]
                deck = x[1]
            }
        }
        hand = evalHand(eval: hand)
        return [hand.theCards, deck]
    }
    if diamondCount == 4 {
        for i in 0..<5 {
            if hand.theCards[i].SUIT != "DIAMOND" {
                let x = changeCard(theHand: hand, myDeck: deck, pos: i)
                hand.theCards = x[0]
                deck = x[1]
            }
        }
        hand = evalHand(eval: hand)
        return [hand.theCards, deck]
    }
    if clubCount == 4 {
        for i in 0..<5 {
            if hand.theCards[i].SUIT != "CLUBS" {
                let x = changeCard(theHand: hand, myDeck: deck, pos: i)
                hand.theCards = x[0]
                deck = x[1]
            }
        }
        hand = evalHand(eval: hand)
        return [hand.theCards, deck]
    }
    // check for 1 away from straight
    // for a possible straight mid section has to be straight-like
    
   
   
    if Int(hand.theCards[1].FACE) == Int(hand.theCards[2].FACE)! - 1 && Int(hand.theCards[2].FACE) == Int(hand.theCards[3].FACE)! - 1 {
        // possibility of a straight swap
        // check the first an last position
        if Int(hand.theCards[0].FACE) == Int(hand.theCards[1].FACE)! - 1 {
            let x = changeCard(theHand: hand, myDeck: deck, pos: 4)
            hand.theCards = x[0]
            deck = x[1]
            hand = evalHand(eval: hand)
            return [hand.theCards, deck]
        } else if Int(hand.theCards[3].FACE) == Int(hand.theCards[4].FACE)! - 1 {
            let x = changeCard(theHand: hand, myDeck: deck, pos: 0)
            hand.theCards = x[0]
            deck = x[1]
            hand = evalHand(eval: hand)
            return [hand.theCards, deck]
        }
    }
    // taking actions based on what the card has
    switch hand.myScore {
    case .High_Card:
        // change bottom four cards
        for i in 0..<4 {
            let x = changeCard(theHand: hand, myDeck: deck, pos: i)
            hand.theCards = x[0]
            deck = x[1]
        }
        break
    case .Pair:
        for i in 0..<4 {
            if hand.theCards[i].FACE == hand.theCards[i+1].FACE {
                pairLocation = i
            }
        }
        for i in 0..<5 where i != pairLocation && i != pairLocation + 1 {
            let x = changeCard(theHand: hand, myDeck: deck, pos: i)
            hand.theCards = x[0]
            deck = x[1]
        }
        break
    case .Two_Pairs:
        if hand.theCards[0].FACE != hand.theCards[1].FACE {
            // change 0
            let x = changeCard(theHand: hand, myDeck: deck, pos: 0)
            hand.theCards = x[0]
            deck = x[1]
        } else if hand.theCards[2].FACE != hand.theCards[3].FACE {
            // change 2
            let x = changeCard(theHand: hand, myDeck: deck, pos: 2)
            hand.theCards = x[0]
            deck = x[1]
        } else if hand.theCards[3].FACE != hand.theCards[4].FACE {
            // change 4
            let x = changeCard(theHand: hand, myDeck: deck, pos: 4)
            hand.theCards = x[0]
            deck = x[1]
        }
        break
    case .Three_of_a_Kind:
        for index in 0..<2 {
            if hand.theCards[index].FACE == hand.theCards[index+2].FACE {
                threeOfAKing.append(index)
                threeOfAKing.append(index + 1)
                threeOfAKing.append(index + 2)
            }
        }
        for i in 0..<5 where i != threeOfAKing[0] && i != threeOfAKing[1] && i != threeOfAKing[2] {
            let x = changeCard(theHand: hand, myDeck: deck, pos: i)
            hand.theCards = x[0]
            deck = x[1]
        }
        break
    case .Straight:
        break
    case .Flush:
        break
    case .Four_of_a_Kind:
        break
    case .Full_House:
        break
    case .Straight_Flush:
        break
    }
    hand = evalHand(eval: hand)
    return [hand.theCards, deck]
}

func changeCard (theHand: hands, myDeck: [cards], pos: Int) -> ([[cards]]) {
    var randomValue : Int
    var hand = theHand
    var deck = myDeck
    hand.theCards[pos].FACE = "empty"
    randomValue = Int.random(in: 0..<52)
    while deck[randomValue].FACE == "empty" {
        randomValue = Int.random(in: 0..<52)
    }
    hand.theCards[pos] = deck[randomValue]
    deck[randomValue].FACE = "empty"
    return [hand.theCards, deck]
}


func compare (hand1:hands, hand2: hands) {
    let comphand = hand1
    let userhand = hand2
    print("the computer has: ")
    for i in comphand.theCards {
        
        switch i.FACE {
        case "11":
            print("J of \(i.SUIT)")
            break
        case "12":
            print("Q of \(i.SUIT)")
            break
        case "13":
            print("K of \(i.SUIT)")
            break
        case "1":
            print("A of \(i.SUIT)")
            break
        default:
            print("\(i.FACE) of \(i.SUIT)")
        }
    }
    print("\n\n")
    print("you have: ")
    for i in userhand.theCards {
        switch i.FACE {
        case "11":
            print("J of \(i.SUIT)")
            break
        case "12":
            print("Q of \(i.SUIT)")
            break
        case "13":
            print("K of \(i.SUIT)")
            break
        case "1":
            print("A of \(i.SUIT)")
            break
        default:
            print("\(i.FACE) of \(i.SUIT)")
        }
    }
    if comphand.myScore.rawValue > userhand.myScore.rawValue {
        print("computer wins")
    } else if comphand.myScore.rawValue < userhand.myScore.rawValue {
        print("you win")
    }
    if  comphand.myScore.rawValue ==  userhand.myScore.rawValue {
        switch comphand.myScore {
        case .High_Card:
            if Int(comphand.theCards[4].FACE)! > Int(userhand.theCards[4].FACE)! {
                print("computer wins")
            } else if Int(comphand.theCards[4].FACE)! < Int(userhand.theCards[4].FACE)! {
                print("user wins")
            } else {
                print("to be coded later")
            }
            break
        case .Pair:
            // find the location at which a pair element is located at
            // then compare the results.
            // declare the larger result as a winner.
            var compPairIndex = 0
            var userPairIndex = 0
            for i in 0..<4 {
                if userhand.theCards[i].FACE == userhand.theCards[i+1].FACE {
                    userPairIndex = i
                }
                if comphand.theCards[i].FACE == comphand.theCards[i+1].FACE {
                    compPairIndex = i
                }
            }
            if Int(comphand.theCards[compPairIndex].FACE)! > Int(userhand.theCards[userPairIndex].FACE)! {
                print("computer wins")
            } else if Int(comphand.theCards[compPairIndex].FACE)! < Int(userhand.theCards[userPairIndex].FACE)! {
                print("user wins")
            }
            break
        default:
            print("default")
        }
    }
}




func evalHand (eval: hands) -> hands {
    var hand = eval
    hand.theCards = sortHand(deck: hand.theCards)
    var pairCounter = 0
    var straight, flush : Bool
    straight = false
    flush = false
    // checking for either high card, pair or two pairs
    for i in 0..<5 {
        for j in i+1..<5 {
            if j == 5 {
                break;
            }
            if hand.theCards[i].FACE == hand.theCards[j].FACE {
                pairCounter = pairCounter + 1
            }
        }
    }
    for i in 0..<3 {
        if hand.theCards[i].FACE == hand.theCards[i+2].FACE {
            hand.myScore = score.Three_of_a_Kind
        }
    }
    
    // based on the pair do these
    if pairCounter == 1 {
        hand.myScore = score.Pair
    } else if pairCounter == 2 {
        hand.myScore = score.Two_Pairs
    } else if pairCounter == 4 {
        hand.myScore = score.Full_House
    } else if pairCounter == 0 {
        hand.myScore = score.High_Card
    }
    
    // checking for four of a kind
    for i in 0..<2 {
        if hand.theCards[i].FACE == hand.theCards[i+3].FACE {
            // three of a kind is set to false since we got a gour of a kind
            hand.myScore = score.Four_of_a_Kind
        }
    }
    // checking for straight
    if (Int(hand.theCards[0].FACE)! == Int(hand.theCards[1].FACE)!-1 && Int(hand.theCards[0].FACE)! == Int(hand.theCards[2].FACE)!-2 && Int(hand.theCards[0].FACE)! == Int(hand.theCards[3].FACE)!-3 &&
        Int(hand.theCards[0].FACE)! == Int(hand.theCards[4].FACE)!-4)  {
        straight = true
        hand.myScore = score.Straight
    }
    // checking for flush
    if ((hand.theCards[0].SUIT) == (hand.theCards[1].SUIT) && (hand.theCards[0].SUIT) == (hand.theCards[2].SUIT) && (hand.theCards[0].SUIT) == (hand.theCards[3].SUIT) &&
        (hand.theCards[0].SUIT) == (hand.theCards[4].SUIT))  {
        flush = true
        hand.myScore = score.Flush
    }
    // checking for a straight flush
    if (straight == true && flush == true) {
        straight = false
        flush = false
        hand.myScore = score.Straight_Flush
    }
    //  *************************
    //  * implement royal flush *
    //  *************************
    
    
    return hand
}



func sortHand (deck: [cards]) -> [cards] {
    print("\n\n\n")
    var evalDeck = deck
    for i in 0..<5 {
        for j in 0..<5-i-1 {
            if Int(evalDeck[j].FACE)! > Int(evalDeck[j+1].FACE)! {
                var temp: cards
                temp = evalDeck[j]
                evalDeck[j] = evalDeck[j+1]
                evalDeck[j+1] = temp
            }
        }
    }
    print("\n\n\n")
    return evalDeck
}

func giveHand (deck: [cards], hand: hands) -> ([[cards]]) {
    var tempDeck = deck
    var tempHand = hand
    var randomValue: Int
    for _ in 0..<5 {
        randomValue = Int.random(in: 0..<52)
        while (tempDeck[randomValue].FACE == "empty") {
             randomValue = Int.random(in: 0..<52)
        }
        tempHand.theCards.append(tempDeck[randomValue])
        tempDeck[randomValue].FACE = "empty"
    }
    tempHand = evalHand(eval: tempHand)
    return [tempHand.theCards, tempDeck]
}

main()








