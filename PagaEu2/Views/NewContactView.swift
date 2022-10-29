//
//  NewContactView.swift
//  PagaEu2
//
//  Created by Paulo Henrique Gomes da Silva on 29/10/22.
//

import SwiftUI

struct NewContactView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode

    @State var name: String = ""

    var body: some View {

        VStack (spacing: 20) {

            Button (action: {

                guard self.name != ""  else { return }

                let newPerson = Contact(context: viewContext)
                newPerson.name = self.name
                newPerson.id = UUID()

                do {

                    try viewContext.save()
                    presentationMode.wrappedValue.dismiss()

                } catch {
                    print(error.localizedDescription)
                }

            }) {
                Text("Save")

            } .padding(.leading, 300)

            Text("Adicionar Novo Contato")
                .font(.headline)
            //                .padding(.trailing, 180.0)
            TextField("Enter Name", text: $name)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            Spacer()
        }
        .padding()
    }
}

struct NewContactView_Previews: PreviewProvider {
    static var previews: some View {
        NewContactView()
    }
}
