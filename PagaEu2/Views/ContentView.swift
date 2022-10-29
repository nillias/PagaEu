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
    
    @State var createNewContacts : Bool = false
    @State var searchText: String = ""
    @State var isFocused : Bool = false

    @State var transactions: [Transactions] = []
    
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
                                    .foregroundColor(.gray)
                                
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
                        NavigationLink(destination: ContactPageView(person: person, transactions: $transactions))
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
            .sheet (isPresented: $createNewContacts) {
                NewContactView()
            }
            .navigationBarItems(trailing:
                                    
                                    Button (action: {
                
                createNewContacts.toggle()
                
            }) {
                
                Image(systemName: "plus")
                    .foregroundColor(.black)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
