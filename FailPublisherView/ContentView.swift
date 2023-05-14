//
//  ContentView.swift
//  FailPublisherView
//
//  Created by sss on 14.05.2023.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @StateObject var viewModel = FailPublisherViewModel()
    
    
    var body: some View {
        VStack {
            Text("\(viewModel.age)")
                .font(.title)
                .foregroundColor(.green)
                .padding()
            TextField("Enter your age", text: $viewModel.text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .padding()
            
            Button("Save") {
                viewModel.save()
            }
        }
        .alert(item: $viewModel.error, content: { error in
            Alert(title: Text("Warning"), message: Text("\(error.rawValue)"))
        })
        .padding()
    }
}

enum InvalidAgeError: String, Error, Identifiable {
    
    //Error - превратит наш enum в обьект с ошибками
    //Identifiable - дает возможность id
    var id: String {
        return rawValue
    }
    
    case lessZero = "Значение не может быть меньше нуля"
    case moreHundred = "Значение не может быть больше 100"
    
}


class FailPublisherViewModel: ObservableObject {
    @Published var text = ""
    @Published var age = 0
    @Published var error: InvalidAgeError?
    
    func save () {
        _ = validationPublisher(age: Int(text) ?? -1)
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                case .finished:
                    break
                }
            }, receiveValue: { [unowned self] value in
                self.age = value
            })
    }
    
    
    func validationPublisher(age: Int) -> AnyPublisher<Int, InvalidAgeError> {
        if age < 0 {
            return Fail(error: InvalidAgeError.lessZero)
                .eraseToAnyPublisher()
        } else if age > 100 {
            return Fail(error: InvalidAgeError.moreHundred)
                .eraseToAnyPublisher()
        }
        return Just(age)
            .setFailureType(to: InvalidAgeError.self)
            .eraseToAnyPublisher()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
