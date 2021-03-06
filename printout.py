import json
import glob
import sys
import pprint as pp
import csv
import os

resdir={}

if len(sys.argv)>1:
    if len(sys.argv)>2:
        print("You passed %d entries probably with shell expansion.  Enclose the glob in quotes" % len(sys.argv))
        exit(1)
    filedir=sys.argv[1]
    files=os.listdir(filedir)
    print(filedir)

with open(os.path.join(filedir,"device-under-test.out")) as file:
    devicepath=file.read()
    devicename=os.path.basename(devicepath)

for filename in files:
    with open(os.path.join(filedir,filename)) as file:
        try:
                #Brute force check for a valid json file.
        	fiojson=json.load(file)
        except:
	        continue
    # We know we have valid json here.
    if "nvme-list" in filename:
        #This is the device name file
        for devices in fiojson["Devices"]:
           if devicename[:6] in devices["DevicePath"]:
              modelName=(devices["ModelNumber"])
        continue
    oio=int(fiojson["global options"]["iodepth"])
    bs=fiojson["global options"]["bs"]
    rw=fiojson["global options"]["rw"]
    iops=float(format(fiojson["jobs"][0]["read"]["iops"],'3.2f'))
    bw_bytes=fiojson["jobs"][0]["read"]["bw_bytes"]
    bw_mbytes=int(bw_bytes/1024)
    resp=1/iops
    respUsec=resp*1000000
    clat_ns=fiojson["jobs"][0]["read"]["clat_ns"]["mean"]
    clat_us=float(format(clat_ns/1000,"3.2f"))
    #print("%3d OIO %s %s : %8d IOPS %d MB/s %5.2f uSec (Littles Law) %5.3f (fio clat) "% (oio,bs,rw,iops,bw_mbytes, respUsec*oio,clat_us))
    #resdir[oio]=str(oio)+str(iops)+str(bw_mbytes)
    resdir[oio]=[int(oio),int(iops),float(clat_us),int(bw_mbytes)]
    

# print output to csv for gnuplot
print("OIO IOPS clat (uSec) MB/s %s %s" % (modelName,devicename))

print(f'{"OIO":>4} {"IOPS":>7} {"clat(Us)":>7} {"MB/s":>8}')
for key in sorted(resdir.keys()):
    oio,iops,clat,mbs=(resdir[key])
    print(f'{oio:4d} {iops:7d} {clat:7.2f} {mbs:8d}')
