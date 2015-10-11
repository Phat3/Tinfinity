//
//  DistanceUtil.swift
//  Tinfinity
//
//  @author Riccardo Mastellone


class DistanceUtil: NSObject {
    
    static func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    static func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    static func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude);
        let lon2 = degreesToRadians(point2.coordinate.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
}