//
//  main.swift
//  pokerGame
//
//  Created by John Demirci on 12/11/19.
//  Copyright © 2019 John Demirci. All rights reserved.
/*
 TODO
    -> get rid of some of the unnecessary eval callings
    -> workon the compare function so that having a draw is not a pssibility
 */
import Foundation
// creating enums for each score of the poker hand
// with this i will determine the winner
enum score: Int {
    case High_Card = 0, Pair, Two_Pairs, Three_of_a_Kind, Straight, Flush, Full_House, Four_of_a_Kind, Straight_Flush, Royal_flush
}

// creating a suit struct to use on each card.
// since each card has a suit and each suit is stronger than another
// i will use a suit value which will determine the winner
struct suits {
    var SUITNAME: String
    var SUITVALUE: Int
}
// each card will have a face and a suit
struct cards {
    var SUIT: suits
    var FACE: String
}
// each hand has 5 cards and a score
struct hands {
    var theCards = [cards]()
    var myScore: score
}

func createDeck () -> [cards] {
    // creating a deck of card type arrays
    var TempDeck = [cards]()
    // creating an array for the name of the suits
    let suitss = ["CLUBS", "DIAMOND", "HEART", "SPADES"]
    
    
    
    // since the face value goes from 2,3,4,5......10,j,q,k,a we star the counter from to
    // insttead of writing down j q k a we represent them by 11 12 13 14
    var counter = 2
    // since there are total of 52 cards we run a loop 52 times to create the deck
    for i in 0..<52 {
        // we have 13 faces but we start from 2 -> 14
        // every time we are about to reach 15 we want to set the counter to 2
        if counter > 14 {
            counter = 2
        }
        // we are adding the deck array the value
        TempDeck.append(.init(SUIT: .init(SUITNAME: suitss[i % 4], SUITVALUE: i % 4), FACE: String(counter)))
        // incrementing the counter
        counter = counter + 1
    }
    // returning the deck we created
    return TempDeck
}

func main () {
    // var deck = [cards]()
    // creating an array of a sfized size
    var deck = createDeck()
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
    // we are creating hand and deck variables because
    // valus passed in the parameter are counted as constant values
    // we want to mamupilate them so we create our own
    var hand = myHand
    var deck = myDeck
    // evalueating before starting anutong
    hand = evalHand(eval: hand)
    // since we do not have j q k a instead we have 11 12 13 14
    // we want to create a way to show these letters instead of numbers
    // here is how i did it
    for i in hand.theCards {
        switch i.FACE {
        case "11":
            print("J of \(i.SUIT.SUITNAME)")
            break
        case "12":
            print("Q of \(i.SUIT.SUITNAME)")
            break
        case "13":
            print("K of \(i.SUIT.SUITNAME)")
            break
        case "14":
            print("A of \(i.SUIT.SUITNAME)")
            break
        default:
            print("\(i.FACE) of \(i.SUIT.SUITNAME)")
        }
    }
    print("how many cards do you want to swap ?")
    // getting the user input
    let amountOfSwapCards: Int = Int(readLine()!)!
    print("please specify the card position one at a time")
    var position: Int
    for _ in 0..<amountOfSwapCards {
        // asking which cards based on their position to swap and get new cards
        position = Int(readLine()!)!
        // calling rhe change cards functions
        // the reason as to why the index is position-1 is becasue
        // it would be better for user to not include the position 0
        // i thought it would be better to start from position 1
        let x = changeCard(theHand: hand, myDeck: deck, pos: position-1)
        hand.theCards = x[0]
        deck = x[1]
    }
    // calling the eval function to sort and and get the new score after the swap
    hand = evalHand(eval: hand)
    return [hand.theCards, deck]
}

func AIdecision (myHand: hands, myDeck: [cards]) -> ([[cards]]) {
    // creating new bariables since the paramters are constant values
    var hand: hands = myHand
    var deck = myDeck
    hand = evalHand(eval: hand)
    // creating some other variables to use lter
    // pairlocation is used to determine the pairs two pairs and full house
    var pairLocation: Int = 0
    // count of the suits are used to make a decision on whether or not
    // to go for a flush
    var diamondCount = 0
    var heartCount = 0
    var clubCount = 0
    var spadesCount = 0
    // threeOfAKing is used to manipulate the three of  kind
    var threeOfAKing = [Int]()
    // if 4/5 the suits are the same
    // the the computer decides to draw one card
    for i in hand.theCards {
        if i.SUIT.SUITNAME == "DIAMOND" {
            diamondCount = diamondCount + 1
        } else if i.SUIT.SUITNAME == "HEART" {
            heartCount = heartCount + 1
        } else if i.SUIT.SUITNAME == "CLUBS" {
            clubCount = clubCount + 1
        } else if i.SUIT.SUITNAME == "SPADES" {
            spadesCount = spadesCount + 1
        }
    }
    // if there are 4 spades then the computer will go for a flush
    if spadesCount == 4 {
        for i in 0..<5 {
            if hand.theCards[i].SUIT.SUITNAME != "SPADES" {
                let x = changeCard(theHand: hand, myDeck: deck, pos: i)
                hand.theCards = x[0]
                deck = x[1]
            }
        }
        hand = evalHand(eval: hand)
        return [hand.theCards, deck]
    }
    // if there are 4 heart then the computer will go for a flush

    if heartCount == 4 {
        for i in 0..<5 {
            if hand.theCards[i].SUIT.SUITNAME != "HEART" {
                let x = changeCard(theHand: hand, myDeck: deck, pos: i)
                hand.theCards = x[0]
                deck = x[1]
            }
        }
        hand = evalHand(eval: hand)
        return [hand.theCards, deck]
    }
    // if there are 4 diamond then the computer will go for a flush

    if diamondCount == 4 {
        for i in 0..<5 {
            if hand.theCards[i].SUIT.SUITNAME != "DIAMOND" {
                let x = changeCard(theHand: hand, myDeck: deck, pos: i)
                hand.theCards = x[0]
                deck = x[1]
            }
        }
        hand = evalHand(eval: hand)
        return [hand.theCards, deck]
    }
    // if there are 4 clubs then the computer will go for a flush

    if clubCount == 4 {
        for i in 0..<5 {
            if hand.theCards[i].SUIT.SUITNAME != "CLUBS" {
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
    
   
    if hand.myScore != score.Straight && hand.myScore != score.Royal_flush {
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
        // checking if value at position i is the same as position i+1
        for i in 0..<4 {
            if hand.theCards[i].FACE == hand.theCards[i+1].FACE {
                // if it satisfies we grab the position
                pairLocation = i
            }
        }
        // when after identifying the position of the pairs
        // we run a for loop where the vlaue i is not at the position where we found the pairs
        // we do not want to swap the pairs we rather want to swap the other cards where there are no relation to something that is related to the pairs
        for i in 0..<5 where i != pairLocation && i != pairLocation + 1 {
            let x = changeCard(theHand: hand, myDeck: deck, pos: i)
            hand.theCards = x[0]
            deck = x[1]
        }
        break
    case .Two_Pairs:
        /*
         since we sort the cards based on the face value starting from 2....14
         we eventually have 3 weak spots when we have two pairs
         the card position where there is no relation to two pairs has to be at
         either at position 0 2 or 4
         the beginning the middle or the end
         
         we basically want to check at these positions and find the one that has no relation to the pairs
         the following statements check to find that spot in the array
         */
        // if position 0 is not the same as the value at position 1 we want to change the
        // value at position 0
        if hand.theCards[0].FACE != hand.theCards[1].FACE {
            // change 0
            let x = changeCard(theHand: hand, myDeck: deck, pos: 0)
            hand.theCards = x[0]
            deck = x[1]
            // if the value at position 2 is not the same as ppsition 3
            // change the value at position 2
        } else if hand.theCards[2].FACE != hand.theCards[3].FACE {
            // change 2
            let x = changeCard(theHand: hand, myDeck: deck, pos: 2)
            hand.theCards = x[0]
            deck = x[1]
            
            // if the value at position 3 is not the same as position 4
            // we change the position 4
        } else if hand.theCards[3].FACE != hand.theCards[4].FACE {
            // change 4
            let x = changeCard(theHand: hand, myDeck: deck, pos: 4)
            hand.theCards = x[0]
            deck = x[1]
        }
        break
    case .Three_of_a_Kind:
        // determinign the positions of the 3 identical cards
        // then we put the positions at the threeofaking array
        for index in 0..<2 {
            if hand.theCards[index].FACE == hand.theCards[index+2].FACE {
                threeOfAKing.append(index)
                threeOfAKing.append(index + 1)
                threeOfAKing.append(index + 2)
            }
        }
        // then like we did in pairs we want to swap the cards that has no relaion to
        // three of a kind
        for i in 0..<5 where i != threeOfAKing[0] && i != threeOfAKing[1] && i != threeOfAKing[2] {
            let x = changeCard(theHand: hand, myDeck: deck, pos: i)
            hand.theCards = x[0]
            deck = x[1]
        }
        break
    case .Straight:
        // when we have straight we have nothing better to do
        break
    case .Flush:
        // when we have flush we have nothing better to do so leave it
        break
    case .Four_of_a_Kind:
        break
    case .Full_House:
        break
    case .Straight_Flush:
        break
    case .Royal_flush:
        break
    }
    // we call eval again
    hand = evalHand(eval: hand)
    // returning
    return [hand.theCards, deck]
}

func changeCard (theHand: hands, myDeck: [cards], pos: Int) -> ([[cards]]) {
    // creating a variable to store the random value into
    var randomValue : Int
    // creating a hand and deck variable so that
    // we can manipulate them because the values passed in the paramter are constant values
    var hand = theHand
    var deck = myDeck
    // we are passing the position we want to change
    // since we already know the position
    
    // we change the value at that position in the hand to "empty"
    hand.theCards[pos].FACE = "empty"
    // then we grab a random value from 0 to 51 41 is included
    randomValue = Int.random(in: 0..<52)
    // we di not want the value at the position randomvalue to be empty so we grab a value until its value is not equal to empty
    while deck[randomValue].FACE == "empty" {
        // while it is equal to empty we run this loop till it is not
        randomValue = Int.random(in: 0..<52)
    }
    // iin our deck at the randomvalue position we want to grab that value and put it inside the hand at the position given
    hand.theCards[pos] = deck[randomValue]
    // since we already grbbed that value we want to set that randomvalue positionat our deck to empty because we grabbed the card
    deck[randomValue].FACE = "empty"
    // returnning
    return [hand.theCards, deck]
}

func listView (hand: hands) {
    // printing the hand with j q k a
    for i in hand.theCards {
        switch i.FACE {
            case "11":
               print("J of \(i.SUIT.SUITNAME)")
               break
           case "12":
               print("Q of \(i.SUIT.SUITNAME)")
               break
           case "13":
               print("K of \(i.SUIT.SUITNAME)")
               break
           case "14":
               print("A of \(i.SUIT.SUITNAME)")
               break
           default:
               print("\(i.FACE) of \(i.SUIT.SUITNAME)")
        }
    }
}


func compare (hand1:hands, hand2: hands) {
    
    // idk why i created these variables i did not need to
    let comphand = hand1
    let userhand = hand2
    // printing out the hands
    print("the computer has: ")
    listView(hand: comphand)
    print("\n\n")
    print("you have: ")
    listView(hand: userhand)
    
    // comparing the score value in the enums
    
    if comphand.myScore.rawValue > userhand.myScore.rawValue {
        print("computer wins")
        winninStatement(hand: comphand)
    } else if comphand.myScore.rawValue < userhand.myScore.rawValue {
        print("you win")
        winninStatement(hand: userhand)
    }
    // if the values are equal then we take a look at the suit values
    if  comphand.myScore.rawValue ==  userhand.myScore.rawValue {
        switch comphand.myScore {
        case .High_Card:
            // if both cards are highcard value we want to
            // take a look at the last position at the each hand because we sort each hand and we know tht highest face value is going to be at the very end of the hand. we basically compare the both hand whichever is higher will be the winner
            if Int(comphand.theCards[4].FACE)! > Int(userhand.theCards[4].FACE)! {
                print("computer wins")
                print("High Card")
            } else if Int(comphand.theCards[4].FACE)! < Int(userhand.theCards[4].FACE)! {
                print("user wins")
                print("High Card")
                // if the have the same face value we then chec their sut value
            } else {
                // check out the suit order
                // Clubs, Diamonds, Hearts, Spades
                if comphand.theCards[4].SUIT.SUITVALUE > userhand.theCards[4].SUIT.SUITVALUE {
                    print("computer wins")
                     print("High Card")
                } else {
                    print("user wins")
                     print("High Card")
                }
            }
            break
        case .Pair:
            // find the location at which a pair element is located at
            // then compare the results.
            // declare the larger result as a winner.
            var compPairIndex = 0
            var userPairIndex = 0
            for i in 0..<4 {
                // getting the index of the pair
                if userhand.theCards[i].FACE == userhand.theCards[i+1].FACE {
                    userPairIndex = i
                }
                // getting the index of the pair
                if comphand.theCards[i].FACE == comphand.theCards[i+1].FACE {
                    compPairIndex = i
                }
            }
            // if the face value of the position of a hand is greater than the value of the  position of the other hand then determine the winner
            if Int(comphand.theCards[compPairIndex].FACE)! > Int(userhand.theCards[userPairIndex].FACE)! {
                print("computer wins")
                print("Pair (High Card)")
            } else if Int(comphand.theCards[compPairIndex].FACE)! < Int(userhand.theCards[userPairIndex].FACE)! {
                print("user wins")
                print("Pair (High Card)")
                // if they have the same face value than determine the winner based on thir suit value
            } else if Int(comphand.theCards[compPairIndex].FACE)! == Int(userhand.theCards[userPairIndex].FACE)! {
                var userPair: Int
                var campPair: Int
                if userhand.theCards[userPairIndex].SUIT.SUITVALUE > userhand.theCards[userPairIndex + 1].SUIT.SUITVALUE {
                    userPair = userPairIndex
                } else {
                    userPair = userPairIndex + 1
                }
                if comphand.theCards[compPairIndex].SUIT.SUITVALUE > comphand.theCards[compPairIndex + 1].SUIT.SUITVALUE {
                    campPair = compPairIndex
                } else {
                    campPair = compPairIndex + 1
                }
                if campPair > userPair {
                    print("Computer wins")
                } else if campPair < userPair {
                    print("User Wins")
                }
            }
            break
        case .Two_Pairs:
            // get the location of the highest pair of each ahnd
            // compare the suit values of the two pairs
            break
        case .Straight:
            if Int(userhand.theCards[4].FACE)! > Int(comphand.theCards[4].FACE)!  {
                print("user wins \nStraight (Pair)")
            } else if Int(userhand.theCards[4].FACE)! < Int(comphand.theCards[4].FACE)!  {
                print("computer wins \nStraight (Pair)")
            } else if  Int(userhand.theCards[4].FACE)! == Int(comphand.theCards[4].FACE)!  {
                if userhand.theCards[4].SUIT.SUITVALUE > comphand.theCards[4].SUIT.SUITVALUE {
                    print("user wins \nStraight (High Card)")
                } else {
                    print("computer wins \nStraight (High Card)")
                }
            }
            break
        case .Flush:
            if Int(userhand.theCards[4].FACE)! > Int(comphand.theCards[4].FACE)!  {
                           print("user wins \nFlush (High)")
                       } else if Int(userhand.theCards[4].FACE)! < Int(comphand.theCards[4].FACE)!  {
                           print("computer wins \nFlush (High)")
                       } else if  Int(userhand.theCards[4].FACE)! == Int(comphand.theCards[4].FACE)!  {
                           if userhand.theCards[4].SUIT.SUITVALUE > comphand.theCards[4].SUIT.SUITVALUE {
                               print("user wins \nFlush (High Card)")
                           } else {
                               print("computer wins \nFlush (High Card)")
                           }
                       }
            break
        default:
            print("default")
        }
    }
}

func winninStatement (hand: hands) {
    switch hand.myScore {
    case .High_Card:
        print("high card")
        break
    case .Flush:
        print("flush")
        break
    case .Four_of_a_Kind:
        print("four of a kind")
        break
    case .Full_House:
        print("full house")
        break
    case .Pair:
        print("pair")
        break
    case .Royal_flush:
        print("Royal Flush")
        break
    case .Straight:
        print("Straight")
        break
    case .Straight_Flush:
        print("Straight Flush")
        break
    case .Three_of_a_Kind:
        print("Three of a Kind")
        break
    case .Two_Pairs:
        print("Two Pairs")
        break
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
    /*
     for i in 0..<3 {
         if hand.theCards[i].FACE == hand.theCards[i+2].FACE {
             hand.myScore = score.Three_of_a_Kind
         }
     }
     */
    // based on the pair do these
    switch pairCounter {
    case 0:
        hand.myScore = score.High_Card
        break
    case 1:
        hand.myScore = score.Pair
        break
    case 2:
        hand.myScore = score.Two_Pairs
        break
    case 3:
        hand.myScore = score.Three_of_a_Kind
        break
    case 4:
        hand.myScore = score.Four_of_a_Kind
        break
    default:
        print("oof")
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
    if ((hand.theCards[0].SUIT.SUITNAME) == (hand.theCards[1].SUIT.SUITNAME) && (hand.theCards[0].SUIT.SUITNAME) == (hand.theCards[2].SUIT.SUITNAME) && (hand.theCards[0].SUIT.SUITNAME) == (hand.theCards[3].SUIT.SUITNAME) &&
        (hand.theCards[0].SUIT.SUITNAME) == (hand.theCards[4].SUIT.SUITNAME))  {
        flush = true
        hand.myScore = score.Flush
    }
    // checking for a straight flush
    if (straight == true && flush == true) {
        straight = false
        flush = false
        hand.myScore = score.Straight_Flush
    }
    if hand.myScore == score.Straight_Flush && hand.theCards[4].SUIT.SUITNAME == "SPADES" && hand.theCards[4].FACE == "14" {
        // royal flush
        hand.myScore = score.Royal_flush
    }
    return hand
}

func sortHand (deck: [cards]) -> [cards] {
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










