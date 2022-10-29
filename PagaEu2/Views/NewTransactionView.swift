//
//  NewTransactionView.swift
//  PagaEu2
//
//  Created by Paulo Henrique Gomes da Silva on 29/10/22.
//

import SwiftUI

struct NewTransactionView: View {
    @Environment (\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode

    @State var amount: String = ""
    @State var date: Date = Date()
    @State var title: String = ""
    @State var save = false

    var contact: Contact

    var body: some View {

        VStack (spacing: 20) {


            Button (action: {
                guard self.amount != "" && self.title != "" else {

                    return

                }

                let transaction = Transactions(context: viewContext)
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                let nsNumber = formatter.number(from:self.amount)

                transaction.amount = nsNumber!.floatValue
                transaction.date = self.date
                transaction.contact = contact
                transaction.title = self.title
                transaction.id = UUID()
                do {
                    try viewContext.save()
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print(error.localizedDescription)
                }

            }) {

                VStack (alignment: .trailing){
                    Button {
                        print("This feat is not working right now, but wait for some updates")} label: {
                            Text("Save")
                                .font(.largeTitle)
                        }

                    if save {
                        Text("This feat is not working right now, but wait for some updates")
                            .font(.largeTitle)
                    }
                }

            }.padding(.leading, 300.0)

            List {

                TextField("R$ 0,00", text: $amount).keyboardType(.decimalPad)
                DatePicker("Data", selection: $date, displayedComponents: .date)

                TextField("Titulo do pagamento", text: $title)

            }

            .listStyle(.plain)

        }
        .padding()

    }
}

//struct NewTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewTransactionView()
//    }
//}
