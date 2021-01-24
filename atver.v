module atver

// import only used functions
import os { exists, file_last_mod_unix }

// Main Watcher struct
pub struct Watcher {
pub mut:
	files  []string
	events chan Event
	done   chan bool
}

// File operation
pub enum Op {
	write
	delete
}

// Event channel struct
struct Event {
pub:
	filename string
	op       Op
}

// Adds file to the watcher
//  -> if the file doesn't exist in the path,
//  it will print a custom error message,
//  -> loop will not break
pub fn (mut w Watcher) add_file(fp string) {
	if w.check_file(fp) {
		w.files << fp

		// start watcher
		go w.watch(fp)
	} else {
		println(' [!err] cannot find $fp in path...')
	}
}

// Removes file to the watcher
// it just deletes it from the array
pub fn (mut w Watcher) remove_file(fp string) {
	w.files.delete(w.files.index(fp))
}

// checks if the files exists in the array
fn (mut w Watcher) check_file(file string) bool {
	// check if file exists
	if exists(file) {
		return true
	}
	// try to remove the file if it is
	// included in the array, but is 
	// removed from the filesystem
	if file in w.files {
		w.remove_file(file)
	}

	return false
}

// MAIN WATCHER
//  -> watches file if modified or removed
//  -> if the file has been deleted from the fs,
//    it will break itself
//  -> it returns common events
fn (mut w Watcher) watch(file string) {
	mut ftime := file_last_mod_unix(file)

	// infinite watching
	for {
		// check if file exists in the array
		if file in w.files {
			// check if file is in path
			if w.check_file(file) {
				// get the current last modified time
				ltime := file_last_mod_unix(file)
				if ltime > ftime {
					ftime = ltime
					// return modified event to the channel
					w.events <- Event{
						filename: file
						op: .write
					}
				}
			} else {
				// return removed event to the channel
				w.events <- Event{
					filename: file
					op: .delete
				}
				// stop the loop watcher
				break
			}
		} else {
			// stop the loop watcher
			break
		}
	}
}

// Close the channel
pub fn (w &Watcher) stop() {
	w.events.close()
}

// Creates a new instance of the watcher struct
pub fn new_watcher() &Watcher {
	// new channel event
	events := chan Event{}

	// watcher instance
	return &Watcher{
		events: events
	}
}
