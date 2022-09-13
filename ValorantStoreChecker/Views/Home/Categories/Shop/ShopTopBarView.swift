//
//  ShopTopBarView.swift
//  ValorantStoreChecker
//
//  Created by Gordon Ng on 2022-07-30.
//

import SwiftUI

struct ShopTopBarView: View {
    
    @EnvironmentObject var authAPIModel : AuthAPIModel
    @EnvironmentObject var skinModel : SkinModel
    
    @State var nowDate: Date = Date()
    
    let defaults = UserDefaults.standard
    
    let referenceDate: Date
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.nowDate = Date()
        }
    }
    
    var body: some View {
        
        HStack {
            
            // MARK: Countdown timer
            Image(systemName: "clock")
                .resizable()
                .scaledToFit()
                .shadow(color: .white, radius: 1)
                .frame(width: 15, height: 15)
                .padding(.leading)
                .padding(.vertical, 10)
            
            let countdown = countDownString(from: referenceDate)
            
            if countdown == "Reload" && (authAPIModel.autoReload || defaults.bool(forKey: "autoReload")) {
                
                // Automatic reloading
                Text(LocalizedStringKey("Reloading"))
                    .bold()
                    .onAppear {
                        Task {
                            authAPIModel.reloading = true
                            await authAPIModel.reload(skinModel: skinModel)
                        }
                    }
                    .font(.caption)
                    .padding(.vertical, 5)
            }
            else if countdown == "Reload" {
                
                Text(LocalizedStringKey("Reload"))
                    .bold()
                    .font(.caption)
                    .padding(.vertical, 5)
                
            }
            else {
                Text(countdown)
                    .bold()
                    .onAppear(perform: {
                        _ = self.timer
                    })
                    .font(.caption)
                    .padding(.vertical, 5)
            }
            
            
            
            
            
            Spacer()
            
            // MARK: Store refresh button
            Button {
                authAPIModel.reloading = true
                Task{
                    await authAPIModel.reload(skinModel: skinModel)
                }
            } label: {
                if !authAPIModel.reloading && !authAPIModel.successfulReload {
                    
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .white, radius: 1)
                        .frame(width: 15, height: 15)
                        .padding(.trailing)
                        .padding(.vertical, 10)
                    
                    
                }
                
                else if authAPIModel.reloading {
                    ProgressView()
                        .shadow(color: .white, radius: 1)
                        .frame(width: 15, height: 15)
                        .padding(.trailing)
                        .padding(.vertical, 10)
                        .onAppear{
                            
                            // TODO: Fix and make smooth animation
                            withAnimation(.easeIn(duration: 0.5)) {
                                authAPIModel.successfulReload = true
                            }
                            
                        }
                }
                
                else if authAPIModel.successfulReload {
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .white, radius: 1)
                        .frame(width: 15, height: 15)
                        .padding(.trailing)
                        .padding(.vertical, 10)
                        .onAppear{
                            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                                withAnimation(.easeIn(duration: 0.5)) {
                                    authAPIModel.successfulReload = false
                                }
                                timer.invalidate()
                            }
                        }
                    
                    
                    
                }
                
                
            }
        }
        .background(Blur(radius: 25, opaque: true))
        .cornerRadius(10)
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 3)
                .offset(y: -1)
                .offset(x: -1)
                .blendMode(.overlay)
                .blur(radius: 0)
                .mask {
                    RoundedRectangle(cornerRadius: 10)
                }
        }
    }
    
    // MARK: Helper function
    func countDownString(from date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        
        let components = calendar
            .dateComponents([.day, .hour, .minute, .second],
                            from: nowDate,
                            to: date)
        
        if components.day! > 0 && (components.hour! > 0 || components.minute! > 0 || components.second! > 0) {
            return String(format: "%02d:%02d:%02d:%02d",
                          components.day ?? 00,
                          components.hour ?? 00,
                          components.minute ?? 00,
                          components.second ?? 00)
        }
        else if components.hour! > 0 || components.minute! > 0 || components.second! > 0 {
            return String(format: "%02d:%02d:%02d",
                          components.hour ?? 00,
                          components.minute ?? 00,
                          components.second ?? 00)
        }
        else {
            
            return "Reload"
            
        }
        
    }
    
}


