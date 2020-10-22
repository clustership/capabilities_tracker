package main

import (
  "os"
  "fmt"
  "io/ioutil"
  "strconv"
  // "strconv"
  "github.com/kinvolk/inspektor-gadget/pkg/gadgettracermanager/containerutils"
)


func main() {

  // ociStatePid, _ := strconv.Atoi(os.Args[1])

  var trackPid int

  if len(os.Args) <= 1 {
    // Parse state from stdin
    stateBuf, err := ioutil.ReadAll(os.Stdin)
    if err != nil {
      panic(fmt.Errorf("cannot read stdin: %v\n", err))
    }

    ociStateID, ociStatePid, err := containerutils.ParseOCIState(stateBuf)
    if err != nil {
      panic(fmt.Errorf("cannot parse stdin: %v\n%s\n", err, string(stateBuf)))
    }

    // Validate state
    if ociStateID == "" || (ociStatePid == 0) { //  && hook == "prestart") {
      panic(fmt.Errorf("invalid OCI state: %v %v", ociStateID, ociStatePid))
    }

    trackPid = ociStatePid
  } else {
     trackPid, _ = strconv.Atoi(os.Args[1])
  }

  // cgroupPathV1, cgroupPathV2, err := containerutils.GetCgroupPaths(ociStatePid)
  cgroupPathV1, cgroupPathV2, err := containerutils.GetCgroupPaths(trackPid)
  if err != nil {
    panic(err)
  }

  // mntNsId, err2 := containerutils.GetMntNs(ociStatePid)
  mntNsId, err2 := containerutils.GetMntNs(trackPid)
  if err2 != nil {
    panic(err2)
  }

  fmt.Printf("CgroupV1: %s\n", cgroupPathV1)
  fmt.Printf("CgroupV2: %s\n", cgroupPathV2)
  fmt.Printf("MntNS: %d\n", mntNsId)

  // mntNsIdB := ([]byte)(strconv.FormatUint(uint64(mntNsId), 10))

  // for _, b := range mntNsIdB {
  //  fmt.Printf("%02x%s", b, " ") // , (i == 7 ? "\n":" "));
  // }
}



