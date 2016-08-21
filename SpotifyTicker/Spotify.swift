//
//  Spotify.swift
//  SpotifyTicker
//
//  Created by elken on 16/08/2016.
//  Copyright © 2016 tdos. All rights reserved.
//

import Cocoa
import AppKit
import ScriptingBridge

@objc internal protocol SBObjectProtocol: NSObjectProtocol {
    func get() -> AnyObject!
}

@objc internal protocol SBApplicationProtocol: SBObjectProtocol {
    func activate()
    var delegate: SBApplicationDelegate! { get set }
}

/// Spotify playback statuses
@objc internal enum SpotifyEPlS : AEKeyword {
    case Stopped = 0x6b505353 /* 'kPSS' */
    case Playing = 0x6b505350 /* 'kPSP' */
    case Paused = 0x6b505370 /* 'kPSp' */
}

/// Wrapper for the Spotify Application itself
@objc internal protocol SpotifyApplication: SBApplicationProtocol {
    @objc optional var currentTrack: SpotifyTrack { get } /// The current playing track.
    @objc optional var soundVolume: Int { get } /// The sound output volume (0 = minimum, 100 = maximum)
    @objc optional var playerState: SpotifyEPlS { get } /// Is Spotify stopped, paused, or playing?
    @objc optional var playerPosition: Double { get } /// The player’s position within the currently playing track in seconds.
    @objc optional var repeatingEnabled: Bool { get } /// Is repeating enabled in the current playback context?
    @objc optional var repeating: Bool { get } /// Is repeating on or off?
    @objc optional var shufflingEnabled: Bool { get } /// Is shuffling enabled in the current playback context?
    @objc optional var shuffling: Bool { get } /// Is shuffling on or off?
    @objc optional func nextTrack() /// Skip to the next track.
    @objc optional func previousTrack() /// Skip to the previous track.
    @objc optional func playpause() /// Toggle play/pause.
    @objc optional func pause() /// Pause playback.
    @objc optional func play() /// Resume playback.
    @objc optional func playTrack(x: String!, inContext: String!) /// Start playback of a track in the given context.
    @objc optional func setSoundVolume(soundVolume: Int) /// The sound output volume (0 = minimum, 100 = maximum)
    @objc optional func setPlayerPosition(playerPosition: Double) /// The player’s position within the currently playing track in seconds.
    @objc optional func setRepeating(repeating: Bool) /// Is repeating on or off?
    @objc optional func setShuffling(shuffling: Bool) /// Is shuffling on or off?
    @objc optional var name: String { get } /// The name of the application.
    @objc optional var frontmost: Bool { get } /// Is this the frontmost (active) application?
    @objc optional var version: String { get } /// The version of the application.
}
extension SBApplication: SpotifyApplication {}

/// Wrapper for the current track
@objc internal protocol SpotifyTrack: SBObjectProtocol {
    @objc optional var artist: String { get } /// The artist of the track.
    @objc optional var album: String { get } /// The album of the track.
    @objc optional var discNumber: Int { get } /// The disc number of the track.
    @objc optional var duration: Int { get } /// The length of the track in seconds.
    @objc optional var playedCount: Int { get } /// The number of times this track has been played.
    @objc optional var trackNumber: Int { get } /// The index of the track in its album.
    @objc optional var starred: Bool { get } /// Is the track starred?
    @objc optional var popularity: Int { get } /// How popular is this track? 0-100
    @objc optional func id() -> String /// The ID of the item.
    @objc optional var name: String { get } /// The name of the track.
    @objc optional var artworkUrl: String { get } /// The URL of the track%apos;s album cover.
    @objc optional var artwork: NSImage { get } /// The property is deprecated and will never be set. Use the 'artwork url' instead.
    @objc optional var albumArtist: String { get } /// That album artist of the track.
    @objc optional var spotifyUrl: String { get } /// The URL of the track.
    @objc optional func setSpotifyUrl(spotifyUrl: String!) /// The URL of the track.
}
extension SBObject: SpotifyTrack {}

/// Controller to manage Spotify operations (also wraps the SpotifyApplication)
class SpotifyController {
    private var spotify = SBApplication(bundleIdentifier: "com.spotify.client") as SpotifyApplication!
    
    /**
    Toggle repeating on/off (currently doesn't handle "repeat one")
    */
    func toggleRepeat() {
        spotify.setRepeating!(!spotify.repeating!.boolValue);
    }
    
    /**
    Toggle shuffling on/off
    */
    func toggleShuffle() {
        spotify.setShuffling!(!spotify.shuffling!.boolValue);
    }
    
    /**
    Check if repeating is on/off (currently doens't handle "repeat one")
    - returns: True/false for repeating status
    */
    func isRepeating() -> Bool {
        return spotify.repeating!.boolValue;
    }
    
    /**
    Check if shuffling is on/off
    - returns: True/false for shuffling status
    */
    func isShuffling() -> Bool {
        return spotify.shuffling!.boolValue;
    }
    
    /**
    Check if a track is currently playing
    - returns: True/false for playing status
    */
    func isPlaying() -> Bool {
        let state = spotify.playerState!
        return state == .Playing;
    }
    
    /**
    Get the current track
    - returns: Current track
    */
    func currentTrack() -> SpotifyTrack {
        return spotify.currentTrack!;
    }
    
    /**
    Get the player position
    - returns: Player position as `Int`
    */
    func playerPosition() -> Int {
        return Int(spotify.playerPosition!);
    }

    /**
    Get album artwork url
    - returns: URL of the artwork of the current song
    */
    func artworkURL() -> String {
        return spotify.currentTrack!.artworkUrl!;
    }
    
    /**
    Advance to the previous track in the playlist. Should
    look into single song playlists.
    */
    func previousTrack() {
        spotify.previousTrack!();
    }
    
    /**
     Advance to the next track in the playlist. Should
     look into single song playlists.
     */
    func nextTrack() {
        spotify.nextTrack!();
    }
    
    /**
    Pause the current song.
    */
    func pause() {
        spotify.pause!();
    }
    
    /**
    Play the current song.
    */
    func play() {
        spotify.play!();
    }
    
    func volume() -> Int {
        return spotify.soundVolume!;
    }
    
    func setVolume(volume: Int) {
        spotify.setSoundVolume!(volume);
    }
}
