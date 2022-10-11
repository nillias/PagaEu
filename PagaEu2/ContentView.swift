//
//  ContentView.swift
//  PagaEu
//
//  Created by Nillia Sousa on 16/05/22.
//

import SwiftUI
import CoreData


extension Float {
    func round(to places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var showNewContactView : Bool = false
    @State var searchText: String = ""
    @State var isFocused : Bool = false
    
    @FetchRequest (entity: Contact.entity(), sortDescriptors: [])
    
    
    var persons: FetchedResults<Contact>
    
    
    
    var body: some View {
        
        
        NavigationView {
            
            VStack{
                
                HStack {
                    
                    TextField("Search", text: $searchText)
                        .frame(height: 20)
                        .padding(10)
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                
                                if self.isFocused {
                                    Button(action: {
                                        self.searchText = ""
                                        
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                        
                                    }
                                }
                                
                            }
                        )
                        .onTapGesture {
                            self.isFocused = true
                        }
                    
                    if isFocused {
                        
                        Button(action: {
                            
                            self.isFocused = false
                            self.searchText = ""
                            
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                        }) {
                            Text("Cancel")
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        //.animation(.default)
                        
                    }
                    
                    let filterPeople = persons.filter {
                        
                        searchText.isEmpty ||
                        ($0.name!.lowercased().prefix(searchText.count) ==
                         searchText.lowercased())
                    }
                    
                    
                }
                .padding(.horizontal, 15)
                .padding(.top, 15)
                
                // Your Search Field Code
                
                let filteredPeople = persons.filter {
                    
                    searchText.isEmpty || ($0.name!.lowercased().prefix(searchText.count) == searchText.lowercased())
 
                }
                
                List {
    
                    ForEach (filteredPeople) { person in
                        NavigationLink(destination: ContactPageView(person: person))
                        {
                            
                            PersonTileView(person: person)
                            
                        }
                        .contextMenu {
                            Button(action: {
                                
                                delete(person: person)
                                
                            }) {
                                
                                Text("Delete")
                                
                            }
                        }
                    }
                }
                
            }
            
            
            
            .navigationTitle("Devedores")
            .sheet (isPresented: $showNewContactView) {
                NewContactView()
            }
            .navigationBarItems(trailing:
                                    
                                    Button (action: {
                
                showNewContactView.toggle()
                
            }) {
                
                Image(systemName: "plus")
            }
                                
            )
            
        }
        
        
    }
    
    func delete (person: Contact) {

        viewContext.delete(person)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }

    }
    
}

struct NewContactView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    
    
    @State var name: String = ""
    
    
    var body: some View {
        
        
        VStack (spacing: 20) {
            
            Button (action: {
                
                guard self.name != ""  else {
                    
                    return
                    
                }
                
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

struct ContactPageView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var person: Contact
    @State var transactions: [Transactions] = []
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
    
    
    
    
    
    
    
    
    
    
    struct NewTransactionView: View {
        
        @Environment (\.managedObjectContext) private var viewContext
        @Environment (\.presentationMode) var presentationMode
        
        @State var amount: String = ""
        @State var date: Date = Date()
        @State var title: String = ""
        
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
                    
                    Text("Save")
                    
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
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ContentView()
                ContentView()
            }
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
