//
//  ContactPageView.swift
//  PagaEu2
//
//  Created by Paulo Henrique Gomes da Silva on 29/10/22.
//

import SwiftUI

struct ContactPageView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var person: Contact
    @Binding var transactions: [Transactions]
    @State var showNewTransactionView: Bool = false

    var body: some View {


        List {
            ForEach(transactions, id: \.self) { transaction in
                HStack {
                    VStack (alignment: .leading, spacing: 7) {
                        Text(transaction.title ?? "").font(.title3).bold()
                        if let date = transaction.date {
                            Text("\(date.formatted(date: .long, time: .omitted))").font(.subheadline).foregroundColor(.gray)

                        }
                    }

                    Spacer()
                    Text("\(transaction.amount)" as String)
                        .bold()
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }.onDelete(perform: removeRows)

        }
        .onAppear(perform: {
            if let unwrapped = person.transactions {
                transactions = Array(_immutableCocoaArray: unwrapped)
            }
        })
        .navigationBarTitle(person.name!)
        .navigationBarItems(trailing:
                                Button (action: {
            showNewTransactionView.toggle()
        }){
            Image(systemName: "plus")
        }
        )
        .sheet(isPresented: $showNewTransactionView) {
            NewTransactionView(contact: person)
        }
    }
    
    func removeRows(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        do {
            try viewContext.save()

        } catch {
            print(error.localizedDescription)
        }

    }
}
    //
    //struct ContactPageView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        ContactPageView(person: <#Contact#>)
    //    }
    //}


