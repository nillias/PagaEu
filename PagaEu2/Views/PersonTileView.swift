//
//  PersonTitleView.swift
//  PagaEu2
//
//  Created by Paulo Henrique Gomes da Silva on 29/10/22.
//

import SwiftUI

struct PersonTileView: View {
    
    @ObservedObject var person: Contact

    var body: some View {

        HStack {

            VStack(alignment: .leading, spacing: 8) {

                Text(person.name!).bold()

                if let transaction = person.transactions?.array as? [Transactions] {

                    if !transaction.isEmpty {

                        Text("Última transação: \(transaction.last!.date!.formatted(date: .numeric, time: .omitted))" as String)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.top, 10.0)
                    }
                } else {

                    Text("No Transactions")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.top, 10.0)
                }
            }
            Spacer()

            if let transactions = person.transactions?.array as? [Transactions] {

                let amount = transactions.map {($0.amount)}.reduce(0,+)
                let currencySymbol = Locale.current.currencySymbol!

                Text("\(currencySymbol) \(amount)")
                    .foregroundColor(Color.green)
            }
        }
        .padding()
    }
}
//
//struct PersonTitleView_Previews: PreviewProvider {
//    static var previews: some View {
////        PersonTileView(person: Contact)
//    }
//}
