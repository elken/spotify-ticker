//
//  PopoverController.swift
//  SpotifyTicker
//
//  Created by elken on 20/08/2016.
//  Copyright © 2016 tdos. All rights reserved.
//

import Cocoa
import Foundation

class PopoverController: NSViewController {
    
    var spotify: SpotifyController! = SpotifyController();
    var preferencesController: PreferencesController = PreferencesController();
    
    var currentArtwork: NSString! = "";
    
    var currentImage: NSImage!
    
    var artworkSize: Int!
    
    @IBOutlet weak var artistLabel: NSTextField!
    @IBOutlet weak var songLabel: NSTextField!
    @IBOutlet weak var albumLabel: NSTextField!
    
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var repeatButton: NSButton!
    @IBOutlet weak var shuffleButton: NSButton!
    
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        updateArtworkSize();
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notify), name: "com.spotify.client.PlaybackStateChanged", object: nil);
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateArtworkSize), name: "com.elken.SpotifyTicker.updateArtworkSize", object: nil);
        
        updateView();
    }
    
    func updateArtworkSize() {
        artworkSize = preferencesController.checkOrDefault("artworkSize", def: 1);
        downloadArtwork();
    }
    
    /**
     Update the relevant view items. Could be lazier.
     */
    func updateView() {
        artistLabel.stringValue = spotify.currentTrack().artist!;
        albumLabel.stringValue = spotify.currentTrack().album!;
        songLabel.stringValue = spotify.currentTrack().name!;
        artistLabel.controlSize = getControlSize(spotify.currentTrack().artist!);
        albumLabel.controlSize = getControlSize(spotify.currentTrack().album!);
        
        playPauseButton.image = NSImage(named: spotify.isPlaying() ? "pauseTemplate" : "playTemplate");
        
        volumeLabel.stringValue = "Volume: \(spotify.volume()) %";
        volumeSlider.integerValue = spotify.volume();
        updateShuffleStatus();
        updateRepeatStatus();
        downloadArtwork();
    }
    
    func getControlSize(str: String) -> NSControlSize {
        if str.characters.count >= 29 {
            return .Small;
        } else {
            return .Regular;
        }
    }
    
    func notify() {
        updateView();
    }
    
    func downloadArtwork() {
        let id = spotify.currentTrack().id!().characters.split{ $0 == ":" }.map(String.init)[2];
        if let url = NSURL(string: "https://api.spotify.com/v1/tracks/\(id)"){
            let request = NSMutableURLRequest(URL: url);
            request.HTTPMethod = "GET";
            
            let session = NSURLSession.sharedSession();
            session.dataTaskWithRequest(request, completionHandler: { (returnData, response, error) -> Void in
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary;
                    let result = jsonResult["album"]!["images"]!![self.artworkSize]["url"]!! as! NSString;
                    if !self.currentArtwork.isEqualToString(result as String) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            let data = NSData(contentsOfURL: NSURL(string: result as String)!);
                            dispatch_async(dispatch_get_main_queue(), {
                                self.currentImage = NSImage(data: data!);
                                if self.imageView != nil {
                                    self.imageView.image = self.currentImage;
                                }
                            });
                        }
                        
                        self.currentArtwork = result;
                    }
                } catch {
                    print("Error parsing.");
                }
                
            }).resume();
        }
        if self.imageView != nil {
            self.imageView.image = self.currentImage;
        }
    }
    
    func updateShuffleStatus() {
        shuffleButton.image = nil;
        shuffleButton.image = NSImage(named: spotify.isShuffling() ? "shufflePressed" : "shuffleTemplate");
    }
    
    func updateRepeatStatus() {
        repeatButton.image = nil;
        repeatButton.image = NSImage(named: spotify.isRepeating() ? "repeatPressed" : "repeatTemplate");
    }
    
    /**
     Action to handle the shuffle box being clicked.
     
     - parameter sender: ID of the object sending this
     */
    @IBAction func shuffleChecked(sender: NSButton) {
        spotify.toggleShuffle();
        updateShuffleStatus();
    }
    
    /**
     Action to handle the repeat box being clicked.
     
     - parameter sender: ID of the object sending this
     */
    @IBAction func repeatChecked(sender: NSButton) {
        spotify.toggleRepeat();
        updateRepeatStatus();
    }
    
    @IBAction func rewindClicked(sender: NSButton) {
        spotify.previousTrack();
    }
    
    @IBAction func forwardClicked(sender: NSButton) {
        spotify.nextTrack();
    }
    
    @IBAction func playPauseClicked(sender: NSButton) {
        playPauseButton.image = nil;
        if (spotify.isPlaying()) {
            spotify.pause();
            playPauseButton.image = NSImage(named: "playTemplate");
        } else {
            spotify.play();
            playPauseButton.image = NSImage(named: "pauseTemplate");
        }
    }
    
    @IBAction func sliderChange(sender: NSSliderCell) {
        volumeLabel.stringValue = "Volume: \(spotify.volume()) %";
        spotify.setVolume(sender.integerValue);
    }
}
