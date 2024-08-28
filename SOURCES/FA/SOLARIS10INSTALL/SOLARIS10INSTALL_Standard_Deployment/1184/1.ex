set timeout 40

trap {
	if [catch {wait -i -1} output] return
	if {[lindex $output [expr [llength $output] -1]] != 0 } {
		exit [lindex $output [expr [llength $output] -1]]
	}
} SIGCHLD

spawn -noecho ssh 10.45.201.16

expect {
	"#*" {
	} default {
		exit 1
	}
}
sleep 0.15
send -- "exit\r"
expect {
	"" {
	} default {
		exit 2
	}
}
sleep 0.15

set timeout 300
expect {
    EOF {}
    timeout { exit 99 }
}
sleep 2
