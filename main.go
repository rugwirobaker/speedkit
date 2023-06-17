package main

import (
	"fmt"
	"os"
	"syscall"
	"time"

	"github.com/rugwirobaker/speedkit/supervisor"
)

func main() {
	var visor = supervisor.New("speedkit", 5*time.Minute)

	visor.AddProcess("iperf3-tcp", "iperf3 --server --port 5201 --bind 0.0.0.0")

	visor.AddProcess("iperf3-udp", "iperf3 --server  --port 5202 --bind fly-global-services")

	visor.StopOnSignal(syscall.SIGINT, syscall.SIGTERM)

	if err := visor.Run(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
