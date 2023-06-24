//
//  ContentView.swift
//  BetterRest
//
//  Created by Khumbongmayum Tonny on 24/06/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeUp
    @State private var sleepAmount: Double = 8.0
    @State private var coffeeAmount: Int = 1
    
//    @State private var sleepTime: Date = calculateBedTime()
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false
    
    static var defaultWakeUp: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                } header: {
                    Text("When do you want to wake up?")
//                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount,in: 4...12 ,step: 0.25)
                } header: {
                    Text("Desire amount of sleep")
//                        .font(.headline)
                }
                
                Section {
                    Picker(coffeeAmount == 1 ? "Number of Cup" : "Number of Cups", selection: $coffeeAmount) {
                        ForEach(1...12, id: \.self) {
                            Text("\(String($0)) \($0 == 1 ? "cup" : "cups")")
                        }
                    }
                } header: {
                    Text("Daily coffe intake")
//                        .font(.headline)
                }
                
                Section {
//                    Text(sleepTime.description)
                    Text("Ideal Bedtime:")
                        .font(.title3.bold())
                    Text(calculateBedTime())
                        .font(.title.bold())
//                    Text(alertMessage)
//                } header: {
//                    Text("Ideal Bedtime")
//                        .font(.title3)
                }

            }
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate") {
////                    calculateBedTime()
//                }
//            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
             Text(alertMessage)
        }
    }
    
  
    func calculateBedTime() -> String {
        var message: String
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            
            let sleepTime = wakeUp - prediction.actualSleep
//            alertTitle = "Your ideal bed time is..."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
//            showingAlert = true
            message = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
//            alertTitle = "Error"
//            alertMessage = "Sorry!, there was a problem calculation your bed time."
            message = "Error"
        }
        return message
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
