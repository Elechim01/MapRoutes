//
//  Home.swift
//  MapRoutes (iOS)
//
//  Created by Michele Manniello on 31/10/21.
//

import SwiftUI
import CoreLocation

struct Home: View {
    @StateObject var mapData = MapViewModel()
//    Location Manager...
    @State var locationManager = CLLocationManager()
    var body: some View {
        ZStack{
//            Map View..
            MapView()
//            using it as environment object so that it can be used ints subViews...
                .environmentObject(mapData)
                .ignoresSafeArea(.all,edges: .all)
            VStack{
                VStack(spacing: 0) {
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search",text: $mapData.serachTxt)
                            .colorScheme(.light)
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal)
                    .background(Color.white)
                    
//                    Displaying Results...
                    if !mapData.places.isEmpty && mapData.serachTxt != ""{
                        ScrollView{
                            VStack(spacing: 15){
                                ForEach(mapData.places){ place in
                                    Text(place.placemark.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                        .padding(.leading)
                                        .onTapGesture {
                                            mapData.selectePlace(place: place)
                                        }
                                    Divider()
                                }
                            }
                            .padding(.top)
                        }
                        .background(Color.white)
                    }
                    
                }.padding()
                
                Spacer()
                VStack{
                    
                    Button {
                        mapData.focusLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        mapData.updateMapType()
                    } label: {
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                    

                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
        }
        .onAppear {
//            setting delegate...
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
        }
//        Permission Denied Alert...
        .alert(isPresented:  $mapData.permissionDenied) {
            Alert(title: Text("Permission Denied"), message: Text("Please Enable Permission In the App Settings"), dismissButton: .default(Text("Goto Settings"),action: {
//                Redireting User To Settings..
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        }
        .onChange(of: mapData.serachTxt) { value in
//            search Places..
//            you can use your own delay time to avoid Continuos Search Request...
            
            let delay = 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if value == mapData.serachTxt{
//                  Seatch...
                    self.mapData.searchQuery()
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
