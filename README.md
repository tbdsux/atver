# atver
Simple file watcher for V-Lang

... nothing fancy here,

### File Operations / Methods Watched:
- Write (modify, chmod)
- Delete (deleting the file from the system)

## Note:
- This module utilizes the builtin library `os`' function `os.file_last_mod_unix`
- API is based from GoLang's `fsnotify`

## Demo
```v
import atver

fn main() {
	// create a new watcher
	mut watcher := atver.new_watcher()

    // not sure about this one, 
    // [this will close the watcher.events channel, .. ]
	defer {
		watcher.stop()
	}

    // create channel
    // so that, the go routine below,
    // will not stop
	done := chan bool{}

	go fn (watcher &atver.Watcher) {
		for {
			select {
				e := <- watcher.events {
					if e.op == .write{
						println('$e.filename is modified')
					} else if e.op == .delete{
						println('$e.filename is removed / renamed')
					}
				}
			}
		}
	}(watcher)
	
    // add files to watch
	watcher.add_file('test.txt')
	watcher.add_file('test.v')
	watcher.add_file('test1.txt')

	done<-true
}
```

### &copy; TheBoringDude