# Two ways to retreive your Windows product key

I have almost no reason to use Windows, but my laptop came with Windows 10 pre-installed on it.
I thought retreiving my Windows product key might still be useful in the future, so here are two ways you can do it.

## From Windows

Windows won't let you find your product key from the settings or from the control panel &mdash; well, at least I couldn't find it.
Fortunately, there is a command you can type in an administrator command prompt (cmd or Powershell, ran as administrator).

```
wmic path softwarelicensingservice get OA3xOriginalProductKey
```

## From Linux

You can get your Windows product key from a simple pseudo-file: `/sys/firmware/acpi/tables/MSDM`.
Just use `more`, or `cat`, or whatever you want to read it's content.

```
sudo cat /sys/firmware/acpi/tables/MSDM
```

The file contains a bit more than the product key, but the product key is present.
It is formatted as such: `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`, at the end of the file.
