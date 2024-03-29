//
//  SignalSafe.m
//  
//
//  Created by Dave DeLong on 5/28/23.
//

#import "SignalSafe.h"

void SafeFormatUInt(char *buffer, int d, size_t length) {
    int remaining = d;
    if (remaining < 0) { return; }
    
    if (d == 0) {
        for (int i = 0; i < length; i++) {
            *buffer = '0';
            buffer++;
        }
    } else {
        double magnitude = floor(log10((double)remaining));
        
        if (magnitude > length) { return; }
        
        int leadingZeroes = length - magnitude - 1;
        for (int i = 0; i < leadingZeroes; i++) {
            *buffer = '0';
            buffer++;
        }
        
        while (magnitude >= 0) {
            int power = (int)pow(10, magnitude);
            int8_t digit = remaining / power;
            *buffer = digit + '0';
            buffer++;
            remaining %= power;
            magnitude -= 1;
        }
    }
}

void SafeFormatHex(char *buffer, int d, size_t length) {
    if (d == 0) {
        for (int i = 0; i < length; i++) {
            *buffer = '0';
            buffer++;
        }
    } else {
        int remaining = d;
        double hexMagnitude = floor(log(remaining)/log(16));
        if (hexMagnitude > length) { return; }
        int leadingZeroes = length - hexMagnitude - 1;
        for (int i = 0; i < leadingZeroes; i++) {
            *buffer = '0';
            buffer++;
        }
        while (hexMagnitude >= 0) {
            int power = (int)pow(16, hexMagnitude);
            int8_t digit = remaining / power;
            
            if (digit < 10) {
                *buffer = digit + '0';
            } else {
                *buffer = (digit - 10) + 'A';
            }
            buffer++;
            remaining %= power;
            hexMagnitude -= 1;
        }
    }
}

void SafeFormatUUID(__darwin_uuid_string_t buffer, uuid_t uuid) {
    SafeFormatHex(buffer, uuid[0], 2);
    SafeFormatHex(buffer+2, uuid[1], 2);
    SafeFormatHex(buffer+4, uuid[2], 2);
    SafeFormatHex(buffer+6, uuid[3], 2);
    buffer[8] = '-';
    SafeFormatHex(buffer+9, uuid[4], 2);
    SafeFormatHex(buffer+11, uuid[5], 2);
    buffer[13] = '-';
    SafeFormatHex(buffer+14, uuid[6], 2);
    SafeFormatHex(buffer+16, uuid[7], 2);
    buffer[18] = '-';
    SafeFormatHex(buffer+19, uuid[8], 2);
    SafeFormatHex(buffer+21, uuid[9], 2);
    buffer[23] = '-';
    SafeFormatHex(buffer+24, uuid[10], 2);
    SafeFormatHex(buffer+26, uuid[11], 2);
    SafeFormatHex(buffer+28, uuid[12], 2);
    SafeFormatHex(buffer+30, uuid[13], 2);
    SafeFormatHex(buffer+32, uuid[14], 2);
    SafeFormatHex(buffer+34, uuid[15], 2);
}
