/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import WatchKit
import Foundation
import CoinKit

class CoinsInterfaceController: WKInterfaceController {
  
    var coins = [Coin]()
    let coinHelper = CoinHelper()
    
    @IBOutlet weak var coinTable: WKInterfaceTable!
    
    
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    coins = coinHelper.cachedPrices()
    reloadTable()
    
    WKInterfaceController.openParentApplication(["request": "refreshData"], reply: { (replyInfo, error) -> Void in
        // Process reply data
        if let coinData = replyInfo["coinData"] as? NSData {
            if let coins = NSKeyedUnarchiver.unarchiveObjectWithData(coinData) as? [Coin] {
                self.coinHelper.cachePriceData(coins)
                self.coins = coins
                self.reloadTable()
            }
        }
    })
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if segueIdentifier == "CoinDetails" {
            let coin = coins[rowIndex]
            return coin
        }
        return nil
    }
    
    func reloadTable() {
        // Set the number of rows and the actual number of coins in the array
        if coinTable.numberOfRows != coins.count {
            coinTable.setNumberOfRows(coins.count, withRowType: "CoinRow")
        }
        
        for(index, coin) in enumerate(coins) {
            // Fetches the object for a particular row
            if let row = coinTable.rowControllerAtIndex(index) as? CoinRow {
                // Set the text for the two labels
                row.titleLabel.setText(coin.name)
                row.detailLabel.setText("\(coin.price)")
            }
        }
    }
    
    override func handleUserActivity(userInfo: [NSObject : AnyObject]!) {
        // Check to see if the coin key and value pair exist in the userInfo dictionary
        if let handedCoin = userInfo["coin"] as? String {
            // You retrieve all the cached coins using the CoinHelper class
            let coins = coinHelper.cachedPrices()
            // Enumertate over the cached coin data
            for coin in coins {
                if coin.name == handedCoin {
                    // Push the detail interface controller onto the navigation stack
                    pushControllerWithName("CoinDetailInterfaceController", context: coin)
                    break
                }
            }
        }
    }

}
