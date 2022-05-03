
<#
.Synopsis
Starts powershell webserver
.Description
Starts webserver as powershell process.
Call of the root page (e.g. http://localhost:8080/) returns a powershell execution web form.
Call of /script uploads a powershell script and executes it (as a function).
Call of /log returns the webserver logs, /starttime the start time of the webserver, /time the current time.
/download downloads and /upload uploads a file. /beep generates a sound and /quit or /exit stops the webserver.
Any other call delivers the static content that fits to the path provided. If the static path is a directory,
a file index.htm, index.html, default.htm or default.html in this directory is delivered if present.

You may have to configure a firewall exception to allow access to the chosen port, e.g. with:
	netsh advfirewall firewall add rule name="Powershell Webserver" dir=in action=allow protocol=TCP localport=8080

After stopping the webserver you should remove the rule, e.g.:
	netsh advfirewall firewall delete rule name="Powershell Webserver"
.Parameter BINDING
Binding of the webserver
.Parameter BASEDIR
Base directory for static content (default: current directory)
.Inputs
None
.Outputs
None
.Example
Start-Webserver

Starts webserver with binding to http://localhost:8080/
.Example
Start-Webserver "http://+:8080/"

Starts webserver with binding to all IP addresses of the system.
Administrative rights are necessary.
.Example
schtasks.exe /Create /TN "Powershell Webserver" /TR "powershell -Command \"Start-WebServer http://+:8080/\" /SC ONSTART /RU SYSTEM /RL HIGHEST /F

Starts powershell webserver as scheduled task as user local system every time the computer starts.
You can start the webserver task manually with
	schtasks.exe /Run /TN "Powershell Webserver"
Delete the webserver task with
	schtasks.exe /Delete /TN "Powershell Webserver"
Scheduled tasks are running with low priority per default, so some functions might be slow.
.Notes
Version 1.2, 2019-08-26
Author: Markus Scholtes
#>
function Start-Webserver
{
	Param([STRING]$BINDING = 'http://localhost:8080/', [STRING]$BASEDIR = "")

	# No adminstrative permissions are required for a binding to "localhost"
	# $BINDING = 'http://localhost:8080/'
	# Adminstrative permissions are required for a binding to network names or addresses.
	# + takes all requests to the port regardless of name or ip, * only requests that no other listener answers:
	# $BINDING = 'http://+:8080/'

	if ($BASEDIR -eq "")
	{	# current filesystem path as base path for static content
		$BASEDIR = (Get-Location -PSProvider "FileSystem").ToString()
	}
	# convert to absolute path
	$BASEDIR = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($BASEDIR)

	# MIME hash table for static content
	$MIMEHASH = @{".avi"="video/x-msvideo"; ".crt"="application/x-x509-ca-cert"; ".css"="text/css"; ".der"="application/x-x509-ca-cert"; ".flv"="video/x-flv"; ".gif"="image/gif"; ".htm"="text/html"; ".html"="text/html"; ".ico"="image/x-icon"; ".jar"="application/java-archive"; ".jardiff"="application/x-java-archive-diff"; ".jpeg"="image/jpeg"; ".jpg"="image/jpeg"; ".js"="application/x-javascript"; ".mov"="video/quicktime"; ".mp3"="audio/mpeg"; ".mp4"="video/mp4"; ".mpeg"="video/mpeg"; ".mpg"="video/mpeg"; ".pdf"="application/pdf"; ".pem"="application/x-x509-ca-cert"; ".pl"="application/x-perl"; ".png"="image/png"; ".rss"="text/xml"; ".shtml"="text/html"; ".txt"="text/plain"; ".war"="application/java-archive"; ".wmv"="video/x-ms-wmv"; ".xml"="text/xml"}

	# HTML answer templates for specific calls, placeholders !RESULT, !FORMFIELD, !PROMPT are allowed
	$HTMLRESPONSECONTENTS = @{
		'GET /'  =  @"
<!doctype html><html><body>
	!HEADERLINE
	<pre>!RESULT</pre>
	<form method="GET" action="/">
	<b>!PROMPT&nbsp;</b><input type="text" maxlength=255 size=80 name="command" value='!FORMFIELD'>
	<input type="submit" name="button" value="Enter">
	</form>
</body></html>
"@
		'GET /script'  =  @"
<!doctype html><html><body>
	!HEADERLINE
	<form method="POST" enctype="multipart/form-data" action="/script">
	<p><b>Script to execute:</b><input type="file" name="filedata"></p>
	<b>Parameters:</b><input type="text" maxlength=255 size=80 name="parameter">
	<input type="submit" name="button" value="Execute">
	</form>
</body></html>
"@
		'GET /download'  =  @"
<!doctype html><html><body>
	!HEADERLINE
	<pre>!RESULT</pre>
	<form method="POST" action="/download">
	<b>Path to file:</b><input type="text" maxlength=255 size=80 name="filepath" value='!FORMFIELD'>
	<input type="submit" name="button" value="Download">
	</form>
</body></html>
"@
		'POST /download'  =  @"
<!doctype html><html><body>
	!HEADERLINE
	<pre>!RESULT</pre>
	<form method="POST" action="/download">
	<b>Path to file:</b><input type="text" maxlength=255 size=80 name="filepath" value='!FORMFIELD'>
	<input type="submit" name="button" value="Download">
	</form>
</body></html>
"@
		'GET /upload'  =  @"
<!doctype html><html><body>
	!HEADERLINE
	<form method="POST" enctype="multipart/form-data" action="/upload">
	<p><b>File to upload:</b><input type="file" name="filedata"></p>
	<b>Path to store on webserver:</b><input type="text" maxlength=255 size=80 name="filepath">
	<input type="submit" name="button" value="Upload">
	</form>
</body></html>
"@
		'POST /script' = "<!doctype html><html><body>!HEADERLINE<pre>!RESULT</pre></body></html>"
		'POST /upload' = "<!doctype html><html><body>!HEADERLINE<pre>!RESULT</pre></body></html>"
		'GET /exit' = "<!doctype html><html><body>Stopped powershell webserver</body></html>"
		'GET /quit' = "<!doctype html><html><body>Stopped powershell webserver</body></html>"
		'GET /log' = "<!doctype html><html><body>!HEADERLINELog of powershell webserver:<br /><pre>!RESULT</pre></body></html>"
		'GET /starttime' = "<!doctype html><html><body>!HEADERLINEPowershell webserver started at $(Get-Date -Format s)</body></html>"
		'GET /time' = "<!doctype html><html><body>!HEADERLINECurrent time: !RESULT</body></html>"
		'GET /beep' = "<!doctype html><html><body>!HEADERLINEBEEP...</body></html>"
	}

	# Set navigation header line for all web pages
	$HEADERLINE = "<p><a href='/'>Command execution</a> <a href='/script'>Execute script</a> <a href='/download'>Download file</a> <a href='/upload'>Upload file</a> <a href='/log'>Web logs</a> <a href='/starttime'>Webserver start time</a> <a href='/time'>Current time</a> <a href='/beep'>Beep</a> <a href='/quit'>Stop webserver</a></p>"

	# Starting the powershell webserver
	"$(Get-Date -Format s) Starting powershell webserver..."
	$LISTENER = New-Object System.Net.HttpListener
	$LISTENER.Prefixes.Add($BINDING)
	$LISTENER.Start()
	$Error.Clear()

	try
	{
		"$(Get-Date -Format s) Powershell webserver started."
		$WEBLOG = "$(Get-Date -Format s) Powershell webserver started.`n"
		while ($LISTENER.IsListening)
		{
			# analyze incoming request
			$CONTEXT = $LISTENER.GetContext()
			$REQUEST = $CONTEXT.Request
			$RESPONSE = $CONTEXT.Response
			$RESPONSEWRITTEN = $FALSE

			# log to console
			"$(Get-Date -Format s) $($REQUEST.RemoteEndPoint.Address.ToString()) $($REQUEST.httpMethod) $($REQUEST.Url.PathAndQuery)"
			# and in log variable
			$WEBLOG += "$(Get-Date -Format s) $($REQUEST.RemoteEndPoint.Address.ToString()) $($REQUEST.httpMethod) $($REQUEST.Url.PathAndQuery)`n"

			# is there a fixed coding for the request?
			$RECEIVED = '{0} {1}' -f $REQUEST.httpMethod, $REQUEST.Url.LocalPath
			$HTMLRESPONSE = $HTMLRESPONSECONTENTS[$RECEIVED]
			$RESULT = ''

			# check for known commands
			switch ($RECEIVED)
			{
				"GET /"
				{	# execute command
					# retrieve GET query string
					$FORMFIELD = ''
					$FORMFIELD = [URI]::UnescapeDataString(($REQUEST.Url.Query -replace "\+"," "))
					# remove fixed form fields out of query string
					$FORMFIELD = $FORMFIELD -replace "\?command=","" -replace "\?button=enter","" -replace "&command=","" -replace "&button=enter",""
					# when command is given...
					if (![STRING]::IsNullOrEmpty($FORMFIELD))
					{
						try {
							# ... execute command
							$RESULT = Invoke-Expression -EA SilentlyContinue $FORMFIELD 2> $NULL | Out-String
						}
						catch
						{
							# just ignore. Error handling comes afterwards since not every error throws an exception
						}
						if ($Error.Count -gt 0)
						{ # retrieve error message on error
							$RESULT += "`nError while executing '$FORMFIELD'`n`n"
							$RESULT += $Error[0]
							$Error.Clear()
						}
					}
					# preset form value with command for the caller's convenience
					$HTMLRESPONSE = $HTMLRESPONSE -replace '!FORMFIELD', $FORMFIELD
					# insert powershell prompt to form
					$PROMPT = "PS $PWD>"
					$HTMLRESPONSE = $HTMLRESPONSE -replace '!PROMPT', $PROMPT
					break
				}

				"GET /script"
				{ # present upload form, nothing to do here
					break
				}

				"POST /script"
				{ # upload and execute script

					# only if there is body data in the request
					if ($REQUEST.HasEntityBody)
					{
						# set default message to error message (since we just stop processing on error)
						$RESULT = "Received corrupt or incomplete form data"

						# check content type
						if ($REQUEST.ContentType)
						{
							# retrieve boundary marker for header separation
							$BOUNDARY = $NULL
							if ($REQUEST.ContentType -match "boundary=(.*);")
							{	$BOUNDARY = "--" + $MATCHES[1] }
							else
							{ # marker might be at the end of the line
								if ($REQUEST.ContentType -match "boundary=(.*)$")
								{ $BOUNDARY = "--" + $MATCHES[1] }
							}

							if ($BOUNDARY)
							{ # only if header separator was found

								# read complete header (inkl. file data) into string
								$READER = New-Object System.IO.StreamReader($REQUEST.InputStream, $REQUEST.ContentEncoding)
								$DATA = $READER.ReadToEnd()
								$READER.Close()
								$REQUEST.InputStream.Close()

								$PARAMETERS = ""
								$SOURCENAME = ""

								# separate headers by boundary string
								$DATA -replace "$BOUNDARY--\r\n", "$BOUNDARY`r`n--" -split "$BOUNDARY\r\n" | ForEach-Object {
									# omit leading empty header and end marker header
									if (($_ -ne "") -and ($_ -ne "--"))
									{
										# only if well defined header (separation between meta data and data)
										if ($_.IndexOf("`r`n`r`n") -gt 0)
										{
											# header data before two CRs is meta data
											# first look for the file in header "filedata"
											if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "Content-Disposition: form-data; name=(.*);")
											{
												$HEADERNAME = $MATCHES[1] -replace '\"'
												# headername "filedata"?
												if ($HEADERNAME -eq "filedata")
												{ # yes, look for source filename
													if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "filename=(.*)")
													{ # source filename found
														$SOURCENAME = $MATCHES[1] -replace "`r`n$" -replace "`r$" -replace '\"'
														# store content of file in variable
														$FILEDATA = $_.Substring($_.IndexOf("`r`n`r`n") + 4) -replace "`r`n$"
													}
												}
											}
											else
											{ # look for other headers (we need "parameter")
												if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "Content-Disposition: form-data; name=(.*)")
												{ # header found
													$HEADERNAME = $MATCHES[1] -replace '\"'
													# headername "parameter"?
													if ($HEADERNAME -eq "parameter")
													{ # yes, look for paramaters
														$PARAMETERS = $_.Substring($_.IndexOf("`r`n`r`n") + 4) -replace "`r`n$" -replace "`r$"
													}
												}
											}
										}
									}
								}

								if ($SOURCENAME -ne "")
								{ # execute only if a source file exists

									$EXECUTE = "function Powershell-WebServer-Func {`n" + $FILEDATA + "`n}`nPowershell-WebServer-Func " + $PARAMETERS
									try {
										# ... execute script
										$RESULT = Invoke-Expression -EA SilentlyContinue $EXECUTE 2> $NULL | Out-String
									}
									catch
									{
										# just ignore. Error handling comes afterwards since not every error throws an exception
									}
									if ($Error.Count -gt 0)
									{ # retrieve error message on error
										$RESULT += "`nError while executing script $SOURCENAME`n`n"
										$RESULT += $Error[0]
										$Error.Clear()
									}
								}
								else
								{
									$RESULT = "No file data received"
								}
							}
						}
					}
					else
					{
						$RESULT = "No client data received"
					}
					break
				}

				{ $_ -like "* /download" } # GET or POST method are allowed for download page
				{	# download file

					# is POST data in the request?
					if ($REQUEST.HasEntityBody)
					{ # POST request
						# read complete header into string
						$READER = New-Object System.IO.StreamReader($REQUEST.InputStream, $REQUEST.ContentEncoding)
						$DATA = $READER.ReadToEnd()
						$READER.Close()
						$REQUEST.InputStream.Close()

						# get headers into hash table
						$HEADER = @{}
						$DATA.Split('&') | ForEach-Object { $HEADER.Add([URI]::UnescapeDataString(($_.Split('=')[0] -replace "\+"," ")), [URI]::UnescapeDataString(($_.Split('=')[1] -replace "\+"," "))) }

						# read header 'filepath'
						$FORMFIELD = $HEADER.Item('filepath')
						# remove leading and trailing double quotes since Test-Path does not like them
						$FORMFIELD = $FORMFIELD -replace "^`"","" -replace "`"$",""
					}
					else
					{ # GET request

						# retrieve GET query string
						$FORMFIELD = ''
						$FORMFIELD = [URI]::UnescapeDataString(($REQUEST.Url.Query -replace "\+"," "))
						# remove fixed form fields out of query string
						$FORMFIELD = $FORMFIELD -replace "\?filepath=","" -replace "\?button=download","" -replace "&filepath=","" -replace "&button=download",""
						# remove leading and trailing double quotes since Test-Path does not like them
						$FORMFIELD = $FORMFIELD -replace "^`"","" -replace "`"$",""
					}

					# when path is given...
					if (![STRING]::IsNullOrEmpty($FORMFIELD))
					{ # check if file exists
						if (Test-Path $FORMFIELD -PathType Leaf)
						{
							try {
								# ... download file
								$BUFFER = [System.IO.File]::ReadAllBytes($FORMFIELD)
								$RESPONSE.ContentLength64 = $BUFFER.Length
								$RESPONSE.SendChunked = $FALSE
								$RESPONSE.ContentType = "application/octet-stream"
								$FILENAME = Split-Path -Leaf $FORMFIELD
								$RESPONSE.AddHeader("Content-Disposition", "attachment; filename=$FILENAME")
								$RESPONSE.AddHeader("Last-Modified", [IO.File]::GetLastWriteTime($FORMFIELD).ToString('r'))
								$RESPONSE.AddHeader("Server", "Powershell Webserver/1.2 on ")
								$RESPONSE.OutputStream.Write($BUFFER, 0, $BUFFER.Length)
								# mark response as already given
								$RESPONSEWRITTEN = $TRUE
							}
							catch
							{
								# just ignore. Error handling comes afterwards since not every error throws an exception
							}
							if ($Error.Count -gt 0)
							{ # retrieve error message on error
								$RESULT += "`nError while downloading '$FORMFIELD'`n`n"
								$RESULT += $Error[0]
								$Error.Clear()
							}
						}
						else
						{
							# ... file not found
							$RESULT = "File $FORMFIELD not found"
						}
					}
					# preset form value with file path for the caller's convenience
					$HTMLRESPONSE = $HTMLRESPONSE -replace '!FORMFIELD', $FORMFIELD
					break
				}

				"GET /upload"
				{ # present upload form, nothing to do here
					break
				}

				"POST /upload"
				{ # upload file

					# only if there is body data in the request
					if ($REQUEST.HasEntityBody)
					{
						# set default message to error message (since we just stop processing on error)
						$RESULT = "Received corrupt or incomplete form data"

						# check content type
						if ($REQUEST.ContentType)
						{
							# retrieve boundary marker for header separation
							$BOUNDARY = $NULL
							if ($REQUEST.ContentType -match "boundary=(.*);")
							{	$BOUNDARY = "--" + $MATCHES[1] }
							else
							{ # marker might be at the end of the line
								if ($REQUEST.ContentType -match "boundary=(.*)$")
								{ $BOUNDARY = "--" + $MATCHES[1] }
							}

							if ($BOUNDARY)
							{ # only if header separator was found

								# read complete header (inkl. file data) into string
								$READER = New-Object System.IO.StreamReader($REQUEST.InputStream, $REQUEST.ContentEncoding)
								$DATA = $READER.ReadToEnd()
								$READER.Close()
								$REQUEST.InputStream.Close()

								# variables for filenames
								$FILENAME = ""
								$SOURCENAME = ""

								# separate headers by boundary string
								$DATA -replace "$BOUNDARY--\r\n", "$BOUNDARY`r`n--" -split "$BOUNDARY\r\n" | ForEach-Object {
									# omit leading empty header and end marker header
									if (($_ -ne "") -and ($_ -ne "--"))
									{
										# only if well defined header (seperation between meta data and data)
										if ($_.IndexOf("`r`n`r`n") -gt 0)
										{
											# header data before two CRs is meta data
											# first look for the file in header "filedata"
											if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "Content-Disposition: form-data; name=(.*);")
											{
												$HEADERNAME = $MATCHES[1] -replace '\"'
												# headername "filedata"?
												if ($HEADERNAME -eq "filedata")
												{ # yes, look for source filename
													if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "filename=(.*)")
													{ # source filename found
														$SOURCENAME = $MATCHES[1] -replace "`r`n$" -replace "`r$" -replace '\"'
														# store content of file in variable
														$FILEDATA = $_.Substring($_.IndexOf("`r`n`r`n") + 4) -replace "`r`n$"
													}
												}
											}
											else
											{ # look for other headers (we need "filepath" to know where to store the file)
												if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "Content-Disposition: form-data; name=(.*)")
												{ # header found
													$HEADERNAME = $MATCHES[1] -replace '\"'
													# headername "filepath"?
													if ($HEADERNAME -eq "filepath")
													{ # yes, look for target filename
														$FILENAME = $_.Substring($_.IndexOf("`r`n`r`n") + 4) -replace "`r`n$" -replace "`r$" -replace '\"'
													}
												}
											}
										}
									}
								}

								if ($FILENAME -ne "")
								{ # upload only if a targetname is given
									if ($SOURCENAME -ne "")
									{ # only upload if source file exists

										# check or construct a valid filename to store
										$TARGETNAME = ""
										# if filename is a container name, add source filename to it
										if (Test-Path $FILENAME -PathType Container)
										{
											$TARGETNAME = Join-Path $FILENAME -ChildPath $(Split-Path $SOURCENAME -Leaf)
										} else {
											# try name in the header
											$TARGETNAME = $FILENAME
										}

										try {
											# ... save file with the same encoding as received
											[IO.File]::WriteAllText($TARGETNAME, $FILEDATA, $REQUEST.ContentEncoding)
										}
										catch
										{
											# just ignore. Error handling comes afterwards since not every error throws an exception
										}
										if ($Error.Count -gt 0)
										{ # retrieve error message on error
											$RESULT += "`nError saving '$TARGETNAME'`n`n"
											$RESULT += $Error[0]
											$Error.Clear()
										}
										else
										{ # success
											$RESULT = "File $SOURCENAME successfully uploaded as $TARGETNAME"
										}
									}
									else
									{
										$RESULT = "No file data received"
									}
								}
								else
								{
									$RESULT = "Missing target file name"
								}
							}
						}
					}
					else
					{
						$RESULT = "No client data received"
					}
					break
				}

				"GET /log"
				{ # return the webserver log (stored in log variable)
					$RESULT = $WEBLOG
					break
				}

				"GET /time"
				{ # return current time
					$RESULT = Get-Date -Format s
					break
				}

				"GET /starttime"
				{ # return start time of the powershell webserver (already contained in $HTMLRESPONSE, nothing to do here)
					break
				}

				"GET /beep"
				{ # Beep
					[CONSOLE]::beep(800, 300) # or "`a" or [char]7
					break
				}

				"GET /quit"
				{ # stop powershell webserver, nothing to do here
					break
				}

				"GET /exit"
				{ # stop powershell webserver, nothing to do here
					break
				}

				default
				{	# unknown command, check if path to file

					# create physical path based upon the base dir and url
					$CHECKDIR = $BASEDIR.TrimEnd("/\") + $REQUEST.Url.LocalPath
					$CHECKFILE = ""
					if (Test-Path $CHECKDIR -PathType Container)
					{ # physical path is a directory
						$IDXLIST = "/index.htm", "/index.html", "/default.htm", "/default.html"
						foreach ($IDXNAME in $IDXLIST)
						{ # check if an index file is present
							$CHECKFILE = $CHECKDIR.TrimEnd("/\") + $IDXNAME
							if (Test-Path $CHECKFILE -PathType Leaf)
							{ # index file found, path now in $CHECKFILE
								break
							}
							$CHECKFILE = ""
						}
						if ($CHECKFILE -eq "")
						{ # generate directory listing
							$HTMLRESPONSE = "<!doctype html><html><head><title>$($REQUEST.Url.LocalPath)</title><meta charset=""utf-8""></head><body><H1>$($REQUEST.Url.LocalPath)</H1><hr><pre>"
							if ($REQUEST.Url.LocalPath -ne "" -And $REQUEST.Url.LocalPath -ne "/" -And $REQUEST.Url.LocalPath -ne "`\"  -And $REQUEST.Url.LocalPath -ne ".")
							{ # link to parent directory
								$PARENTDIR = (Split-Path $REQUEST.Url.LocalPath -Parent) -replace '\\','/'
								if ($PARENTDIR.IndexOf("/") -ne 0) { $PARENTDIR = "/" + $PARENTDIR }
								$HTMLRESPONSE += "<pre><a href=""$PARENTDIR"">[To Parent Directory]</a><br><br>"
							}

							# read in directory listing
							$ENTRIES = Get-ChildItem -EA SilentlyContinue -Path $CHECKDIR

							# process directories
							$ENTRIES | Where-Object { $_.PSIsContainer } | ForEach-Object { $HTMLRESPONSE += "$($_.LastWriteTime.ToString())       &lt;dir&gt; <a href=""$(Join-Path $REQUEST.Url.LocalPath $_.Name)"">$($_.Name)</a><br>" }

							# process files
							$ENTRIES | Where-Object { !$_.PSIsContainer } | ForEach-Object { $HTMLRESPONSE += "$($_.LastWriteTime.ToString())  $("{0,10}" -f $_.Length) <a href=""$(Join-Path $REQUEST.Url.LocalPath $_.Name)"">$($_.Name)</a><br>" }

							# end of directory listing
							$HTMLRESPONSE += "</pre><hr></body></html>"
						}
					}
					else
						{ # no directory, check for file
							if (Test-Path $CHECKDIR -PathType Leaf)
							{ # file found, path now in $CHECKFILE
								$CHECKFILE = $CHECKDIR
							}
						}

					if ($CHECKFILE -ne "")
					{ # static content available
						try {
							# ... serve static content
							$BUFFER = [System.IO.File]::ReadAllBytes($CHECKFILE)
							$RESPONSE.ContentLength64 = $BUFFER.Length
							$RESPONSE.SendChunked = $FALSE
							$EXTENSION = [IO.Path]::GetExtension($CHECKFILE)
							if ($MIMEHASH.ContainsKey($EXTENSION))
							{ # known mime type for this file's extension available
								$RESPONSE.ContentType = $MIMEHASH.Item($EXTENSION)
							}
							else
							{ # no, serve as binary download
								$RESPONSE.ContentType = "application/octet-stream"
								$FILENAME = Split-Path -Leaf $CHECKFILE
								$RESPONSE.AddHeader("Content-Disposition", "attachment; filename=$FILENAME")
							}
							$RESPONSE.AddHeader("Last-Modified", [IO.File]::GetLastWriteTime($CHECKFILE).ToString('r'))
							$RESPONSE.AddHeader("Server", "Powershell Webserver/1.2 on ")
							$RESPONSE.OutputStream.Write($BUFFER, 0, $BUFFER.Length)
							# mark response as already given
							$RESPONSEWRITTEN = $TRUE
						}
						catch
						{
							# just ignore. Error handling comes afterwards since not every error throws an exception
						}
						if ($Error.Count -gt 0)
						{ # retrieve error message on error
							$RESULT += "`nError while downloading '$CHECKFILE'`n`n"
							$RESULT += $Error[0]
							$Error.Clear()
						}
					}
					else
					{	# no file to serve found, return error
						if (!(Test-Path $CHECKDIR -PathType Container))
						{
							$RESPONSE.StatusCode = 404
							$HTMLRESPONSE = '<!doctype html><html><body>Page not found</body></html>'
						}
					}
				}

			}

			# only send response if not already done
			if (!$RESPONSEWRITTEN)
			{
				# insert header line string into HTML template
				$HTMLRESPONSE = $HTMLRESPONSE -replace '!HEADERLINE', $HEADERLINE

				# insert result string into HTML template
				$HTMLRESPONSE = $HTMLRESPONSE -replace '!RESULT', $RESULT

				# return HTML answer to caller
				$BUFFER = [Text.Encoding]::UTF8.GetBytes($HTMLRESPONSE)
				$RESPONSE.ContentLength64 = $BUFFER.Length
				$RESPONSE.AddHeader("Last-Modified", [DATETIME]::Now.ToString('r'))
				$RESPONSE.AddHeader("Server", "Powershell Webserver/1.2 on ")
				$RESPONSE.OutputStream.Write($BUFFER, 0, $BUFFER.Length)
			}

			# and finish answer to client
			$RESPONSE.Close()

			# received command to stop webserver?
			if ($RECEIVED -eq 'GET /exit' -or $RECEIVED -eq 'GET /quit')
			{ # then break out of while loop
				"$(Get-Date -Format s) Stopping powershell webserver..."
				break;
			}
		}
	}
	finally
	{
		# Stop powershell webserver
		$LISTENER.Stop()
		$LISTENER.Close()
		"$(Get-Date -Format s) Powershell webserver stopped."
	}
}






<#
.Synopsis
Splits a file to smaller files with choosable size.
.Description
Splits a file to smaller files with choosable size.
The source file remains unchanged.
The resulting files have the name of the source file with an appended forthcounting number.
.Parameter Path
Path of the source file
.Parameter NewSize
Size of the splitted parts (default is 100MB)
.Inputs
None
.Outputs
None
.Example
Split-File "BigFile.dat" 10000000

Divides the file BigFile.dat into parts of 10000000 byte size
.Notes
Author: Markus Scholtes
Version: 1.01
Date: 2020-05-03
#>
function Split-File([STRING] $Path, [INT64] $Newsize = 100MB)
{
	if ($Newsize -le 0)
	{
		Write-Error "Only positive sizes allowed"
		return
	}

	"Splitting file $Path to parts of $Newsize byte size"
	$FILEPATH = [IO.Path]::GetDirectoryName($Path)
	if ($FILEPATH -ne "") { $FILEPATH = $FILEPATH + "\" }
	$FILENAME = [IO.Path]::GetFileNameWithoutExtension($Path)
	$EXTENSION  = [IO.Path]::GetExtension($Path)

	$MAXVALUE = 1GB # Hard maximum limit for Byte array for 64-Bit .Net 4 = [INT32]::MaxValue - 56, see here https://stackoverflow.com/questions/3944320/maximum-length-of-byte
	# but only around 1.5 GB in 32-Bit environment! So I chose 1 GB just to be safe
	$PASSES = [MATH]::Floor($Newsize / $MAXVALUE)
	$REMAINDER = $Newsize % $MAXVALUE
	if ($PASSES -gt 0) { $BUFSIZE = $MAXVALUE } else { $BUFSIZE = $REMAINDER }

	$OBJREADER = New-Object System.IO.BinaryReader([System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))
	[Byte[]]$BUFFER = New-Object Byte[] $BUFSIZE
	$NUMFILE = 1

	do {
		$NEWNAME = "{0}{1}{2,2:00}{3}" -f ($FILEPATH, $FILENAME, $NUMFILE, $EXTENSION)

		$COUNT = 0
		$OBJWRITER = $NULL
		[INT32]$BYTESREAD = 0
		while (($COUNT -lt $PASSES) -and (($BYTESREAD = $OBJREADER.Read($BUFFER, 0, $BUFFER.Length)) -gt 0))
		{
			if (!$OBJWRITER)
			{
				$OBJWRITER = New-Object System.IO.BinaryWriter([System.IO.File]::Create($NEWNAME))
				"Writing to file $NEWNAME"
			}
			"Reading $BYTESREAD bytes of $Path"
			$OBJWRITER.Write($BUFFER, 0, $BYTESREAD)
			$COUNT++
		}
		if (($REMAINDER -gt 0) -and (($BYTESREAD = $OBJREADER.Read($BUFFER, 0, $REMAINDER)) -gt 0))
		{
			if (!$OBJWRITER)
			{
				$OBJWRITER = New-Object System.IO.BinaryWriter([System.IO.File]::Create($NEWNAME))
				"Writing to file $NEWNAME"
			}
			"Reading $BYTESREAD bytes of $Path"
			$OBJWRITER.Write($BUFFER, 0, $BYTESREAD)
		}

		if ($OBJWRITER) { $OBJWRITER.Close() }
		++$NUMFILE
	} while ($BYTESREAD -gt 0)

	$OBJREADER.Close()
}


<#
.Synopsis
Joins files whose names or filesystem objects are handed in the pipeline to one target file
.Description
Joins files whose names or filesystem objects are handed in the pipeline to one target file.
If the target file exists it will be overwritten. The source files remain unchanged.
.Parameter Path
Path to the source file
.Inputs
Array of strings or filesystem objects
.Outputs
None
.Example
dir *.pdf | Join-File All.pdf

Joins all PDF files to target file All.pdf
.Example
"E.pdf", "C.pdf", "G.pdf", "V.pdf", "P.pdf"| Join-File .\Result.dat

Joins the listed PDF files to target file Result.dat
.Notes
Author: Markus Scholtes
Version: 1.0
Date: 2017-09-04
#>
function Join-File([STRING] $Path)
{
	if ((!$Path) -or ($Path -eq ""))
	{	Write-Error "Target filename missing."
		return
	}

	$OBJARRAY = @($INPUT)
	if ($OBJARRAY.Count -eq 0)
	{	Write-Error "Source filename list missing."
		return
	}

	$OBJWRITER = New-Object System.IO.BinaryWriter([System.IO.File]::Create($Path))

	$OBJARRAY | ForEach-Object {
		"Appending $_ to $Path."
		$OBJREADER = New-Object System.IO.BinaryReader([System.IO.File]::Open($_, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))

		$OBJWRITER.BaseStream.Position = $OBJWRITER.BaseStream.Length
		$OBJREADER.BaseStream.CopyTo($OBJWRITER.BaseStream)
		$OBJWRITER.BaseStream.Flush()

		$OBJREADER.Close()
	}

	$OBJWRITER.Close()
}






<#
.Synopsis
Replaces text in files while preserving the encoding
.Description
Replaces text in files while preserving the encoding. Optionally, the file's time information is kept as well.
The result is output to the pipeline if no -Overwrite is specified.
If the encoding can not be determined, ASCII is assumed.
(Obviously this is no Set but a Replace operation, but there is no verb for Replace actions in the Powershell naming guidelines)
.Parameter Pattern
Search as a regular expression
.Parameter Replacement
Replaced text
.Parameter Path
File or directory name
.Parameter Recurse
Work files recursively in subdirectories
.Parameter CaseSensitive
Case-sensitive search
.Parameter Unix
For search patterns with end of line, this is searched for as a Unix line end (only NewLine instead of LineFeed + NewLine)
.Parameter Overwrite
The edited texts are copied to the original files (instead of given to the pipeline)
.Parameter Force
For -Overwrite: Even unchanged texts are written to the original files
.Parameter PreserveDate
The modified files retain the original time stamps
.Parameter Quiet
No output at the console
.Parameter OEM
Files in ASCII format are processed with OEM character set 850 (instead of Windows character set 1252)
.Parameter Encoding
Force writing of files in this encoding
.Inputs
File names can be passed over the pipeline
.Outputs
Edited texts, if not -Overwrite is specified
.Example
Replace-InFile -Pattern "Mister" -Replacement "Lady" -Path Test.txt -Quiet > result.txt

Replaces Mister with Lady in the file "Test.txt" and writes the result to result.txt
.Example
dir | Replace-InFile -Pattern "12" -Replacement "34" -Overwrite

Replaces 12 with 34 in all files of the current directory
.Example
gci | Replace-InFile -Pattern "late" -Replacement "later" -CaseSensitive -Recurse -OEM

Replaces late with later in all files of the current directory and all subdirectories.
The case is case-sensitive. ASCII files are interpreted as OEM files.
The result is not written back to the files, but is output to the pipeline.
.Example
Get-ChildItem "*.txt" | Replace-InFile -Pattern "t$" -Replacement "T" -Encoding UNICODE -Overwrite

Replaces t at the end of the line with T in all txt files of the current directory.
The files are written in UNICODE encoding.
.Example
Get-ChildItem "*.txt" | Replace-InFile -Pattern "t\r\n" -Replacement "T\r\n" -Overwrite

Replaces t at the end of the line with T in all txt files of the current directory.
.Example
"*.txt" | Replace-InFile -Pattern "<NL>" -Replacement "`n" -enc "Ascii" -VERBOSE

Replaces <NL> with an end of line in all txt files of the current directory.
The result is output in ASCII encoding. There is a verbose output.
.Example
Replace-InFile -Pattern "away" -Path "*.txt" -Overwrite -PreserveDate -WhatIf

Removes the expression away in all txt files of the current directory, preserving the time stamp of the
files. No change is made because of the switch -WhatIf.
.Example
Replace-InFile "*" -patt "Search" -repl "Replace" -rec -enc UTF8 -u -over

Replaces Search with Replace in all files of the current directory and all subdirectories.
UTF8 is written as encoding, line breaks are interpreted as Unix line breaks.
.Notes
Author: Markus Scholtes
Version: 1.0
Date: 2017-02-06
#>
function Replace-InFile
{
	[CmdletBinding(SupportsShouldProcess=$TRUE)]
	param(
		[parameter(Mandatory=$TRUE, Position=0)] [STRING]$Pattern,
		[parameter(Position=1)] [STRING][AllowEmptyString()]$Replacement,
		[parameter(Mandatory=$FALSE, Position=2, ValueFromPipeline=$TRUE)] [STRING][AllowEmptyString()]$Path,
		[SWITCH]$CaseSensitive,
		[SWITCH]$Unix,
		[SWITCH]$Overwrite,
		[SWITCH]$Force,
		[SWITCH]$Recurse,
		[SWITCH]$PreserveDate,
		[SWITCH]$Quiet,
		[SWITCH]$OEM,
		[Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$Encoding = "Unknown"
	)


	BEGIN
	{
		function Get-FileEncoding {
		##############################################################################
		##
		## Get-FileEncoding
		##
		## From Windows PowerShell Cookbook (O'Reilly)
		## by Lee Holmes (http://www.leeholmes.com/guide)
		##
		## expandend and switched to FileSystemCmdletProviderEncoding
		## by Markus Scholtes, 2014
		##
		##############################################################################
		<#

		.SYNOPSIS

		Gets the encoding of a file

		.EXAMPLE

		Get-FileEncoding.ps1 .\UnicodeScript.ps1

		Unicode

		.EXAMPLE

		Get-ChildItem *.ps1 | Select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'}

		This command gets ps1 files in current directory where encoding is not ASCII

		.EXAMPLE

		Get-ChildItem *.ps1 | Select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(Get-Content $_.FullName) | Set-Content $_.FullName -Encoding ASCII}

		Same as previous example but fixes encoding using set-content

		#>

		## The path of the file to get the encoding of.
		param($PATH)

		# Markus Scholtes, 2014
		# converts Encoding value of type [System.Text.Encoding] to type [Microsoft.Powershell.Commands.FileSystemCmdletProviderEncoding]
		#
		# Example
		# Convert-EncodingType ([System.Text.Encoding]::'ASCII')
		# Types can be output by using:
		#[Microsoft.Powershell.Commands.FileSystemCmdletProviderEncoding] | gm -Static -MemberType Property
		#[System.Text.Encoding] | gm -Static -MemberType Property

		function Convert-EncodingType([System.Text.Encoding]$KODIERUNG)
		{
			if ($KODIERUNG)
			{	[Microsoft.Powershell.Commands.FileSystemCmdletProviderEncoding]$KODIERUNG.BodyName.ToUpper().Replace("US-","").Replace("-","").Replace("UNICODEFFFE","BigEndianUnicode").Replace("UTF16BE","BigEndianUnicode").Replace("UTF16","Unicode").Replace("ISO88591","Default") }
			else
			{ $NULL }
		}

		Set-StrictMode -Version Latest

		## The hashtable used to store our mapping of encoding bytes to their
		## name. For example, "255-254 = Unicode"
		$ENCODINGS = @{}

		## Find all of the encodings understood by the .NET Framework. For each,
		## determine the bytes at the start of the file (the preamble) that the .NET
		## Framework uses to identify that encoding.
		$ENCODINGMEMBERS = [System.Text.Encoding] | Get-Member -Static -MemberType Property

		$ENCODINGMEMBERS | Foreach-Object {
			$ENCODINGBYTES = [System.Text.Encoding]::($_.Name).GetPreamble() -join '-'
			$ENCODINGS[$ENCODINGBYTES] = $_.Name
		}

		## Find out the lengths of all of the preambles.
		$ENCODINGLENGTHS = $ENCODINGS.Keys | Where-Object { $_ } | Foreach-Object { ($_ -split "-").Count }

		## Assume the encoding is ASCII by default
		$RESULT = "ASCII"

		if (($NULL -ne $PATH) -and ($PATH -ne "")) {
			if (Get-Content $PATH)
			{
				## Go through each of the possible preamble lengths, read that many bytes
				## from the file, and then see if it matches one of the encodings we know
				## about.
				foreach ($ENCODINGLENGTH in $ENCODINGLENGTHS | Sort-Object -Descending)
				{
					$BYTES = (Get-Content -Encoding BYTE -Readcount $ENCODINGLENGTH $PATH)[0]
					$ENCODING = $ENCODINGS[$BYTES -join '-']

					## If we found an encoding that had the same preamble bytes, save that
					## output and break.
					if ($ENCODING)
					{
						$RESULT = $ENCODING
						break
					}
				}
			}
		}

		## Finally, output the encoding.
		Convert-EncodingType ([System.Text.Encoding]::$RESULT)
		}

		# Working function
		function Request-File([STRING]$Name)
		{
			if (!$Quiet) { Write-Output "Processing file '$Name'" }

			if ($PreserveDate)
			{	$Datei = Get-Item "$Name"
				$LastAccess = $Datei.LastAccessTime
				$Creation = $Datei.CreationTime
				$LastWrite = $Datei.LastWriteTime
			}

			# determine the current encoding of the source file
			$ActualEncoding = Get-FileEncoding "$Name"

			# ReadAllText must be used to read the contents of the file
			# so it is inserted into a string and not a string array
			try {
				Write-Verbose "Reading file $Name."
				if ($ActualEncoding -eq "ASCII")
				{ # ASCII-Encoding, select the right codepage for the umlauts
					if ($OEM)
					{ # DOS codepage
						$Inhalt = [IO.File]::ReadAllText($Name, [System.Text.Encoding]::GetEncoding(850))
					}
					else
					{ # Windows codepage
						$Inhalt = [IO.File]::ReadAllText($Name, [System.Text.Encoding]::GetEncoding(1252))
					}
				}
				else
				{ # other encoding, ReadAllText recognizes the correct one
					$Inhalt = [IO.File]::ReadAllText($Name)
				}
				Write-Verbose "Read from file $Name finished."
			}
			catch [Management.Automation.MethodInvocationException]
			{
				Write-Error $ERROR[0]
				return
			}

			if (!$Quiet) { Write-Output "$($RegEx.Matches($Inhalt).Count) matches" }

			if (-not $Overwrite)
			{
				if (-not $WHATIFPREFERENCE)
				{
					$RegEx.Replace($Inhalt, $Replacement)
				}
				return
			}

			if ($Force -or ($Inhalt -cne $RegEx.Replace($Inhalt, $Replacement)))
			{
				Write-Verbose "Writing to $Name."
				if (-not $WHATIFPREFERENCE)
				{
					try
					{
						if ($Encoding -eq "Unknown")
						{ # if parameter Encoding is not set, keep current encoding
							Write-Verbose "Using current encoding $ActualEncoding"
							$TargetEncoding = $ActualEncoding
						}
						else
						{ # use chosen encoding
							$TargetEncoding = $Encoding
						}
						if ($TargetEncoding -eq "ASCII")
						{ # ASCII-Encoding, select the right codepage for the umlauts
							if ($OEM)
							{ # DOS codepage
								[IO.File]::WriteAllText("$Name", $RegEx.Replace($Inhalt, $Replacement), [System.Text.Encoding]::GetEncoding(850))
							}
							else
							{ # Windows codepage
								[IO.File]::WriteAllText("$Name", $RegEx.Replace($Inhalt, $Replacement), [System.Text.Encoding]::GetEncoding(1252))
							}
						}
						else
						{ # andere Kodierung
							[IO.File]::WriteAllText("$Name", $RegEx.Replace($Inhalt, $Replacement), [System.Text.Encoding]::$TargetEncoding)
						}
					}
					catch [Management.Automation.MethodInvocationException]
					{
						Write-Error $ERROR[0]
						return
					}
				}

				if ($PreserveDate)
				{	# Set time stamp to original
					Write-Verbose "Setting original time stamp of the file."
					if (-not $WHATIFPREFERENCE) {
						$Datei.LastAccessTime = $LastAccess
						$Datei.CreationTime = $Creation
						$Datei.LastWriteTime = $LastWrite
					}
				}
				Write-Verbose "Writing to $Name finished."
			}
			else
			{
				if (!$Quiet) {
					if ($Inhalt -eq "")
					{ Write-Output "File is empty." } else { Write-Output "No change in text." }
				}
			}
		}

		# Replace "$" with "\r$" in regular expression (not if -Unix is set)
		# \$ has to be preserved
		if (-not $Unix)
		{
			$NewPattern = $Pattern -replace '(?<!\\)\$', '\r$'
		}
		else
		{
			Write-Verbose 'Search for "Unix" linefeed.'
			$NewPattern = $Pattern
		}

		# create array of Regex options and the RegEx object
		$Options = @()
		$Options += "Multiline"
		if (-not $CaseSensitive)
		{ $Options += "IgnoreCase" } else { Write-Verbose 'Case-sensitive search.' }

		$RegEx = New-Object Text.RegularExpressions.Regex $NewPattern, $Options
		if ($Encoding -eq "Unknown")
		{ Write-Verbose "Use current encoding." } else { Write-Verbose "Use encoding $Encoding." }

	}

	PROCESS
	{
		# parameter or pipeline object is handed to $Path
		if ($_ -ne $Null)
		{ # when there is a name in the pipeline, use it
			$Name = $_
		} else {
			$Name = $Path
		}

		if (($Name -is [System.IO.FileInfo]) -or ($Name -is [System.IO.DirectoryInfo]))
		{ # if it is a FileInfo object or a DirectoryInfo object, determine path name
			$FileObject = $Name
		}
		else
		{ # if it is a String, determine complete path name and object
			$FileObject = Get-Item $Name -ErrorAction 'SilentlyContinue'

			# no file or directory found, end function
			if ($Null -eq $FileObject) { return }

			# more than one object found
			if ($FileObject -is [System.Array])
			{ # call Replace-InFile for every file
				foreach ($FileName in $FileObject) { Replace-InFile -Pattern "$Pattern" -Replacement "$Replacement" -Path "$FileName" -CaseSensitive:$CaseSensitive -Unix:$Unix -Overwrite:$Overwrite -Force:$Force -PreserveDate:$PreserveDate -OEM:$OEM -Encoding $Encoding -Recurse:$Recurse -Quiet:$Quiet }
				# and end function
				return
			}
		}
		$Name = $FileObject.FullName

		if (Test-Path $Name)
		{ # if the path exists

			# is it a directory?
			if ($FileObject.PsIsContainer)
			{ # recursion?
				# yes -> then call Replace-InFile with child objects
				# no -> do nothing
				if ($Recurse)
				{ Get-ChildItem $Name | Replace-InFile -Pattern "$Pattern" -Replacement "$Replacement" -CaseSensitive:$CaseSensitive -Unix:$Unix -Overwrite:$Overwrite -Force:$Force -PreserveDate:$PreserveDate -OEM:$OEM -Encoding $Encoding -Recurse -Quiet:$Quiet }
			}
			else
			{ # it is a file -> call working function
				Request-File $Name
			}
		}
	}
}




<#
.SYNOPSIS
Removes firewall rules according to a list in a CSV or JSON file.
.DESCRIPTION
Removes firewall rules according to a with Export-FirewallRules generated list in a CSV or JSON file.
CSV files have to be separated with semicolons. Only the field Name or - if Name is missing - DisplayName
is used, alle other fields can be omitted
anderen
.PARAMETER CSVFile
Input file
.PARAMETER JSON
Input in JSON instead of CSV format
.PARAMETER PolicyStore
Store from which rules are removed (default: PersistentStore).
Allowed values are PersistentStore, ActiveStore (the resultant rule set of all sources), localhost,
a computer name, <domain.fqdn.com>\<GPO_Friendly_Name> and others depending on the environment.
.NOTES
Author: Markus Scholtes
Version: 1.1.0
Build date: 2020/12/12
.EXAMPLE
Remove-FirewallRules
Removes all firewall rules according to a list in the CSV file FirewallRules.csv in the current directory.
.EXAMPLE
Remove-FirewallRules WmiRules.json -json
Removes all firewall rules according to the list in the JSON file WmiRules.json.
#>
function Remove-FirewallRules
{
	Param($CSVFile = "", [SWITCH]$JSON, [STRING]$PolicyStore = "PersistentStore")

	#Requires -Version 4.0


	if (!$JSON)
	{ # read CSV file
		if ([STRING]::IsNullOrEmpty($CSVFile)) { $CSVFile = ".\FirewallRules.csv" }
		$FirewallRules = Get-Content $CSVFile | ConvertFrom-CSV -Delimiter ";"
	}
	else
	{ # read JSON file
		if ([STRING]::IsNullOrEmpty($CSVFile)) { $CSVFile = ".\FirewallRules.json" }
		$FirewallRules = Get-Content $CSVFile | ConvertFrom-JSON
	}

	# iterate rules
	ForEach ($Rule In $FirewallRules)
	{
		$CurrentRule = $NULL
		if (![STRING]::IsNullOrEmpty($Rule.Name))
		{
			$CurrentRule = Get-NetFirewallRule -EA SilentlyContinue -Name $Rule.Name
			if (!$CurrentRule)
			{
				Write-Error "Firewall rule `"$($Rule.Name)`" does not exist"
				continue
			}
		}
		else
		{
			if (![STRING]::IsNullOrEmpty($Rule.DisplayName))
			{
				$CurrentRule = Get-NetFirewallRule -EA SilentlyContinue -DisplayName $Rule.DisplayName
				if (!$CurrentRule)
				{
					Write-Error "Firewall rule `"$($Rule.DisplayName)`" does not exist"
					continue
				}
			}
			else
			{
				Write-Error "Failure in data record"
				continue
			}
		}

		Write-Output "Removing firewall rule `"$($CurrentRule.DisplayName)`" ($($CurrentRule.Name))"
		Get-NetFirewallRule -EA SilentlyContinue -PolicyStore $PolicyStore -Name $CurrentRule.Name | Remove-NetFirewallRule
	}
}

<#
.SYNOPSIS
Imports firewall rules from a CSV or JSON file.
.DESCRIPTION
Imports firewall rules from with Export-FirewallRules generated CSV or JSON files. CSV files have to
be separated with semicolons. Existing rules with same display name will be overwritten.
.PARAMETER CSVFile
Input file
.PARAMETER JSON
Input in JSON instead of CSV format
.PARAMETER PolicyStore
Store to which the rules are written (default: PersistentStore).
Allowed values are PersistentStore, ActiveStore (the resultant rule set of all sources), localhost,
a computer name, <domain.fqdn.com>\<GPO_Friendly_Name> and others depending on the environment.
.NOTES
Author: Markus Scholtes
Version: 1.1.0
Build date: 2020/12/12
.EXAMPLE
Import-FirewallRules
Imports all firewall rules in the CSV file FirewallRules.csv in the current directory.
.EXAMPLE
Import-FirewallRules WmiRules.json -json
Imports all firewall rules in the JSON file WmiRules.json.
#>
function Import-FirewallRules
{
	Param($CSVFile = "", [SWITCH]$JSON, [STRING]$PolicyStore = "PersistentStore")

	#Requires -Version 4.0

	# convert comma separated list (String) to Stringarray
	function ListToStringArray([STRING]$List, $DefaultValue = "Any")
	{
		if (![STRING]::IsNullOrEmpty($List))
		{	return ($List -split ",")	}
		else
		{	return $DefaultValue}
	}

	# convert value (String) to boolean
	function ValueToBoolean([STRING]$Value, [BOOLEAN]$DefaultValue = $FALSE)
	{
		if (![STRING]::IsNullOrEmpty($Value))
		{
			if (($Value -eq "True") -or ($Value -eq "1"))
			{ return $TRUE }
			else
			{	return $FALSE }
		}
		else
		{
			return $DefaultValue
		}
	}


	if (!$JSON)
	{ # read CSV file
		if ([STRING]::IsNullOrEmpty($CSVFile)) { $CSVFile = ".\FirewallRules.csv" }
		$FirewallRules = Get-Content $CSVFile | ConvertFrom-CSV -Delimiter ";"
	}
	else
	{ # read JSON file
		if ([STRING]::IsNullOrEmpty($CSVFile)) { $CSVFile = ".\FirewallRules.json" }
		$FirewallRules = Get-Content $CSVFile | ConvertFrom-JSON
	}

	# iterate rules
	ForEach ($Rule In $FirewallRules)
	{ # generate Hashtable for New-NetFirewallRule parameters
		$RuleSplatHash = @{
			Name = $Rule.Name
			Displayname = $Rule.Displayname
			Description = $Rule.Description
			Group = $Rule.Group
			Enabled = $Rule.Enabled
			Profile = $Rule.Profile
			Platform = ListToStringArray $Rule.Platform @()
			Direction = $Rule.Direction
			Action = $Rule.Action
			EdgeTraversalPolicy = $Rule.EdgeTraversalPolicy
			LooseSourceMapping = ValueToBoolean $Rule.LooseSourceMapping
			LocalOnlyMapping = ValueToBoolean $Rule.LocalOnlyMapping
			LocalAddress = ListToStringArray $Rule.LocalAddress
			RemoteAddress = ListToStringArray $Rule.RemoteAddress
			Protocol = $Rule.Protocol
			LocalPort = ListToStringArray $Rule.LocalPort
			RemotePort = ListToStringArray $Rule.RemotePort
			IcmpType = ListToStringArray $Rule.IcmpType
			DynamicTarget = if ([STRING]::IsNullOrEmpty($Rule.DynamicTarget)) { "Any" } else { $Rule.DynamicTarget }
			Program = $Rule.Program
			Service = $Rule.Service
			InterfaceAlias = ListToStringArray $Rule.InterfaceAlias
			InterfaceType = $Rule.InterfaceType
			LocalUser = $Rule.LocalUser
			RemoteUser = $Rule.RemoteUser
			RemoteMachine = $Rule.RemoteMachine
			Authentication = $Rule.Authentication
			Encryption = $Rule.Encryption
			OverrideBlockRules = ValueToBoolean $Rule.OverrideBlockRules
		}

		# for SID types no empty value is defined, so omit if not present
		if (![STRING]::IsNullOrEmpty($Rule.Owner)) { $RuleSplatHash.Owner = $Rule.Owner }
		if (![STRING]::IsNullOrEmpty($Rule.Package)) { $RuleSplatHash.Package = $Rule.Package }

		Write-Output "Generating firewall rule `"$($Rule.DisplayName)`" ($($Rule.Name))"
		# remove rule if present
		Get-NetFirewallRule -EA SilentlyContinue -PolicyStore $PolicyStore -Name $Rule.Name | Remove-NetFirewallRule

		# generate new firewall rule, parameter are assigned with splatting
		New-NetFirewallRule -EA Continue -PolicyStore $PolicyStore @RuleSplatHash
	}
}




<#
.Synopsis
Inserts a file as a segment into an existing file or overwrites parts of the existing file.
.Description
Inserts a file as a segment into an existing file or overwrites parts of the existing file.
If no target file name is specified, the original file is overwritten.
.Parameter SourceFile
Path to source file
.Parameter InsertFile
Path to the file which is inserted as a segment
.Parameter TargetFile
Path to target file. If this parameter is omitted, the source file will be overwritten
.Parameter Position
Starting point in source file where the file is inserted
.Parameter Replace
From Position source file is overwritten instead of inserted (standard mode: insert).
If the length of InsertFile is greater than the rest of the source file starting from Position, the file
is enlarged
.Inputs
None
.Outputs
None
.Example
Import-FileSegment Originalfile.dat Insertdata.dat Patchedfile.dat 1024

Inserts the content of "Insertdata.dat" into "Originalfile.dat" starting at position 1024 and saves the result to
"Patchedfile.dat". The source file "Originalfile.dat" remains unchanged.
.Example
Import-FileSegment -SourceFile Originalfile.dat -InsertFile Insertdata.dat -Position 0x0400 -Replace

Inserts the content of "Insertdata.dat" into "Originalfile.dat" starting at position 1024 with overwriting the
content of "Originalfile.dat" and writing back the result to "Originalfile.dat".
.Notes
Author: Markus Scholtes
Created: 2020/07/12
#>
function Import-FileSegment([Parameter(Mandatory = $TRUE)][STRING] $SourceFile, [Parameter(Mandatory = $TRUE)][STRING] $InsertFile, [STRING] $TargetFile, [int] $Position = 0, [SWITCH] $Replace)
{
    if ($Position -lt 0)
    {
        Write-Error "Position in file must be greater than or equal to 0"
        return
    }

    try {
        $SourceSize = (Get-ChildItem $SourceFile -ErrorAction Stop).Length
    }
    catch {
        Write-Error "Source file $SourceFile does not exist"
        return
    }

    try {
        $InsertSize = (Get-ChildItem $InsertFile -ErrorAction Stop).Length
    }
    catch {
        Write-Error "Insert file $InsertFile does not exist"
        return
    }

    if ($InsertSize -eq 0)
    {
        Write-Error "Insert file $InsertFile must not be an empty file"
        return
    }

    if ($Position -gt $SourceSize)
    {
        Write-Error "Position must be within the source file"
        return
    }

    $TEMPFILE = "$ENV:TEMP\$((Get-ChildItem $SourceFile).Name)"
    try {
        $OBJWRITER = New-Object System.IO.BinaryWriter([System.IO.File]::Create($TEMPFILE))
    }
    catch {
        Write-Error "Error while creating the temporary file"
        return
    }

    # Schreibe Inhalt vor Einfügung
    if ($Position -gt 0)
    {
        Write-Output "Write content from $SourceFile up to position $Position"
        [Byte[]]$BUFFER = New-Object Byte[] $Position

        try {
            $OBJREADER = New-Object System.IO.BinaryReader([System.IO.File]::Open($SourceFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))
            $BYTESREAD = $OBJREADER.Read($BUFFER, 0, $Position)
            $OBJWRITER.Write($BUFFER, 0, $BYTESREAD)
            $OBJREADER.Close()
        }
        catch {
            Write-Error $_
            $OBJREADER.Close()
            $OBJWRITER.Close()
            return
        }
    }

    # Schreibe Einfügung
    Write-Output "Write content from $InsertFile"
    try {
        $OBJREADER = New-Object System.IO.BinaryReader([System.IO.File]::Open($InsertFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))
        $OBJWRITER.BaseStream.Position = $OBJWRITER.BaseStream.Length
        $OBJREADER.BaseStream.CopyTo($OBJWRITER.BaseStream)
        $OBJWRITER.BaseStream.Flush()
        $OBJREADER.Close()
    }
    catch {
        Write-Error $_
        $OBJREADER.Close()
        $OBJWRITER.Close()
        return
    }

    # Schreibe Inhalt nach Einfügung
    if ($Replace)
    { # Replace old content at $Position, so continue behind insertion
        $Position += $InsertSize
    }

    if ($Position -lt $SourceSize)
    {
        Write-Output "Write content from $SourceFile starting with position $Position"
        try {
            $OBJREADER = New-Object System.IO.BinaryReader([System.IO.File]::Open($SourceFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))
            $OBJREADER.BaseStream.Position = $Position
            $OBJREADER.BaseStream.CopyTo($OBJWRITER.BaseStream)
            $OBJWRITER.BaseStream.Flush()
            $OBJREADER.Close()
        }
        catch {
            Write-Error $_
            $OBJREADER.Close()
            $OBJWRITER.Close()
            return
        }
    }

    $OBJWRITER.Close()

    if ([STRING]::IsNullOrEmpty($TargetFile)) { $TargetFile = $SourceFile }
    Write-Output "Create target file $TargetFile"
    Move-Item -Path $TEMPFILE -Destination $TargetFile -Force
}


<#
.SYNOPSIS
Exports firewall rules to a CSV or JSON file.
.DESCRIPTION
Exports firewall rules to a CSV or JSON file. Local and policy based rules will be given out.
CSV files are semicolon separated (Beware! Excel is not friendly to CSV files).
All rules are exported by default, you can filter with parameter -Name, -Inbound, -Outbound,
-Enabled, -Disabled, -Allow and -Block.
.PARAMETER Name
Display name of the rules to be processed. Wildcard character * is allowed.
.PARAMETER CSVFile
Output file
.PARAMETER JSON
Output in JSON instead of CSV format
.PARAMETER PolicyStore
Store from which the rules are retrieved (default: ActiveStore).
Allowed values are PersistentStore, ActiveStore (the resultant rule set of all sources), localhost,
a computer name, <domain.fqdn.com>\<GPO_Friendly_Name>, RSOP and others depending on the environment.
.PARAMETER Inbound
Export inbound rules
.PARAMETER Outbound
Export outbound rules
.PARAMETER Enabled
Export enabled rules
.PARAMETER Disabled
Export disabled rules
.PARAMETER Allow
Export allowing rules
.PARAMETER Block
Export blocking rules
.NOTES
Author: Markus Scholtes
Version: 1.1.0
Build date: 2020/12/12
.EXAMPLE
Export-FirewallRules
Exports all firewall rules to the CSV file FirewallRules.csv in the current directory.
.EXAMPLE
Export-FirewallRules -Inbound -Allow
Exports all inbound and allowing firewall rules to the CSV file FirewallRules.csv in the current directory.
.EXAMPLE
Export-FirewallRules snmp* SNMPRules.json -json
Exports all SNMP firewall rules to the JSON file SNMPRules.json.
#>
function Export-FirewallRules
{
    Param($Name = "*", $CSVFile = "", [SWITCH]$JSON, [STRING]$PolicyStore = "ActiveStore", [SWITCH]$Inbound, [SWITCH]$Outbound, [SWITCH]$Enabled, [SWITCH]$Disabled, [SWITCH]$Block, [SWITCH]$Allow)

    #Requires -Version 4.0

    # convert Stringarray to comma separated liste (String)
    function StringArrayToList($StringArray)
    {
        if ($StringArray)
        {
            $Result = ""
            Foreach ($Value In $StringArray)
            {
                if ($Result -ne "") { $Result += "," }
                $Result += $Value
            }
            return $Result
        }
        else
        {
            return ""
        }
    }

    # Filter rules?
    # Filter by direction
    $Direction = "*"
    if ($Inbound -And !$Outbound) { $Direction = "Inbound" }
    if (!$Inbound -And $Outbound) { $Direction = "Outbound" }

    # Filter by state
    $RuleState = "*"
    if ($Enabled -And !$Disabled) { $RuleState = "True" }
    if (!$Enabled -And $Disabled) { $RuleState = "False" }

    # Filter by action
    $Action = "*"
    if ($Allow -And !$Block) { $Action  = "Allow" }
    if (!$Allow -And $Block) { $Action  = "Block" }


    # read firewall rules
    $FirewallRules = Get-NetFirewallRule -DisplayName $Name -PolicyStore $PolicyStore | Where-Object { $_.Direction -like $Direction -and $_.Enabled -like $RuleState -And $_.Action -like $Action }

    # start array of rules
    $FirewallRuleSet = @()
    ForEach ($Rule In $FirewallRules)
    { # iterate through rules
        Write-Output "Processing rule `"$($Rule.DisplayName)`" ($($Rule.Name))"

        # Retrieve addresses,
        $AdressFilter = $Rule | Get-NetFirewallAddressFilter
        # ports,
        $PortFilter = $Rule | Get-NetFirewallPortFilter
        # application,
        $ApplicationFilter = $Rule | Get-NetFirewallApplicationFilter
        # service,
        $ServiceFilter = $Rule | Get-NetFirewallServiceFilter
        # interface,
        $InterfaceFilter = $Rule | Get-NetFirewallInterfaceFilter
        # interfacetype
        $InterfaceTypeFilter = $Rule | Get-NetFirewallInterfaceTypeFilter
        # and security settings
        $SecurityFilter = $Rule | Get-NetFirewallSecurityFilter

        # generate sorted Hashtable
        $HashProps = [PSCustomObject]@{
            Name = $Rule.Name
            DisplayName = $Rule.DisplayName
            Description = $Rule.Description
            Group = $Rule.Group
            Enabled = $Rule.Enabled
            Profile = $Rule.Profile
            Platform = StringArrayToList $Rule.Platform
            Direction = $Rule.Direction
            Action = $Rule.Action
            EdgeTraversalPolicy = $Rule.EdgeTraversalPolicy
            LooseSourceMapping = $Rule.LooseSourceMapping
            LocalOnlyMapping = $Rule.LocalOnlyMapping
            Owner = $Rule.Owner
            LocalAddress = StringArrayToList $AdressFilter.LocalAddress
            RemoteAddress = StringArrayToList $AdressFilter.RemoteAddress
            Protocol = $PortFilter.Protocol
            LocalPort = StringArrayToList $PortFilter.LocalPort
            RemotePort = StringArrayToList $PortFilter.RemotePort
            IcmpType = StringArrayToList $PortFilter.IcmpType
            DynamicTarget = $PortFilter.DynamicTarget
            Program = $ApplicationFilter.Program -Replace "$($ENV:SystemRoot.Replace("\","\\"))\\", "%SystemRoot%\" -Replace "$(${ENV:ProgramFiles(x86)}.Replace("\","\\").Replace("(","\(").Replace(")","\)"))\\", "%ProgramFiles(x86)%\" -Replace "$($ENV:ProgramFiles.Replace("\","\\"))\\", "%ProgramFiles%\"
            Package = $ApplicationFilter.Package
            Service = $ServiceFilter.Service
            InterfaceAlias = StringArrayToList $InterfaceFilter.InterfaceAlias
            InterfaceType = $InterfaceTypeFilter.InterfaceType
            LocalUser = $SecurityFilter.LocalUser
            RemoteUser = $SecurityFilter.RemoteUser
            RemoteMachine = $SecurityFilter.RemoteMachine
            Authentication = $SecurityFilter.Authentication
            Encryption = $SecurityFilter.Encryption
            OverrideBlockRules = $SecurityFilter.OverrideBlockRules
        }

        # add to array with rules
        $FirewallRuleSet += $HashProps
    }

    if (!$JSON)
    { # output rules in CSV format
        if ([STRING]::IsNullOrEmpty($CSVFile)) { $CSVFile = ".\FirewallRules.csv" }
        $FirewallRuleSet | ConvertTo-CSV -NoTypeInformation -Delimiter ";" | Set-Content $CSVFile
    }
    else
    { # output rules in JSON format
        if ([STRING]::IsNullOrEmpty($CSVFile)) { $CSVFile = ".\FirewallRules.json" }
        $FirewallRuleSet | ConvertTo-JSON | Set-Content $CSVFile
    }
}



<#
.Synopsis
Writes a segment of a file to a new file
.Description
Writes a segment of a file to a new file. The source file will not be changed.
The length of the segment can be determined via block size or end position.
If no segment length is specified the rest of the file is written as segment.
.Parameter Path
Path to source file
.Parameter Target
Path to target file
.Parameter Start
Starting point of segment in source file
.Parameter End
Ending point of segment in source file (is preferred before specifying -Size)
.Parameter Size
Size of the segment in the file (specification of -End is preferred)
.Inputs
None
.Outputs
None
.Example
Export-FileSegment LargeFile.dat Extract.dat 0x1000000 0x1001000

Extracts 4096 bytes from LargeFile.dat starting at position 16777216 and writes them to file Extract.dat
.Example
Export-FileSegment -Path "C:\Users\He\Pictures\sample.jpg" -Target ".\Header.dat" -Start 0 -Size 11

Reads the 11 bytes of the JPEG header from the image and writes it to Header.dat in the current directory
.Notes
Autor: Markus Scholtes
Created: 2018, translated 2020/06/30
#>
function Export-FileSegment([Parameter(Mandatory = $TRUE)][STRING] $Path, [Parameter(Mandatory = $TRUE)][STRING] $Target, [int] $Start = 0, [int] $End = -1, [int] $Size = -1)
{
    if ($Start -lt 0)
    {
        Write-Error "Start position in file must be greater than or equal to 0"
        return
    }
    if ($End -ge 0)
    {
        if ($Start -gt $End)
        {
            Write-Error "End position in file must be greater than or equal to start position"
            return
        }
        $Size = $End - $Start
    }

    Write-Output "Processing file '$Path'"
    try {
        $OBJREADER = New-Object System.IO.BinaryReader([System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))
    }
    catch {
        Write-Error "Error opening '$Path'"
        return
    }
    if ($Start -gt [int]$OBJREADER.BaseStream.Length)
    {
        $OBJREADER.Close()
        Write-Error "Start position must not be larger than file size"
        return
    }

    if ($Size -lt 0) { $Size = [int]$OBJREADER.BaseStream.Length - $Start   }

    [Byte[]]$BUFFER = New-Object Byte[] $Size
    [int]$BYTESREAD = 0

    if ($Start -gt 0) { $OBJREADER.BaseStream.Seek($Start, [System.IO.SeekOrigin]::Begin) | Out-Null }

    Write-Output "Reading $Size bytes at position $Start"
    if (($BYTESREAD = $OBJREADER.Read($BUFFER, 0, $BUFFER.Length)) -ge 0)
    {
        Write-Output "Read $BYTESREAD bytes from '$Path'"
        Write-Output "Writing file '$Target'"
        try {
            $OBJWRITER = New-Object System.IO.BinaryWriter([System.IO.File]::Create($Target))
            $OBJWRITER.Write($BUFFER, 0, $BYTESREAD)
            $OBJWRITER.Close()
        }
        catch {
            Write-Error "Error writing '$Target'"
        }
    }
    $OBJREADER.Close()
}


<#
.Synopsis
Generate cmd.exe batch files from short Powershell scripts
.Description
Generate cmd.exe batch files from short Powershell scripts
The Powershell scripts are Base64 encoded and handed to a new Powershell instance in the batch file.
If special characters like umlauts are used in the script it has to be UTF8 encoded to preserve the special characters.
The following restrictions apply to the generated batch files:
- the script may have a maximum of 2975 characters (because of Unicode and Base64 encoding and the maximum parameter length of 8192 characters in cmd.exe)
- the execution policy is ignored
- all parameters are handed to the batch files as strings
- only position parameters are possible for the batch files (no named parameters)
- a maximum of 9 parameters are possible for the batch files
- default values for parameters do not work
.Parameter Path
Filename(s)
.Inputs
Filenames can be passed through the pipeline
.Outputs
None
.Example
ConvertTo-Batch -Path Test.ps1

Converts the Powershell script "Test.ps1" to "Test.bat"
.Example
dir *.ps1 | ConvertTo-Batch

Converts all Powershell scripts in the current directory to batch files
.Example
ConvertTo-Batch -Path ".\test.ps1", ".\test2.ps1", "c:\Data\demo.ps1"

Converts the passed Powershell scripts to batch files
.Notes
Author: Markus Scholtes, 24.02.2018
Idea: http://community.idera.com/powershell/powertips/b/tips/posts/converting-powershell-to-batch
#>
function ConvertTo-Batch
{ # file names can be passed per parameter or pipeline
    param([Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)][Alias("FullName")]$Path)

    BEGIN
    { # initialize counter
        $COUNTCONVERTED = 0
    }

    PROCESS
    {   # found more than one object
        if ($Path -is [System.Array])
        { # call for each object
          foreach ($File in $Path) { ConvertTo-Batch $File }
          # and exit function
          return
        }

        if (Test-Path -Path $Path -PathType Leaf)
        {   # file found, check extension
            if ([IO.Path]::GetExtension($Path) -eq ".ps1")
            {   # convert only Powershell scripts
                $CONTENT = "function _CT_B_{"
                $CONTENT += Get-Content -Path $Path -Raw -Encoding UTF8
                $CONTENT += "`n};_CT_B_ `$ENV`:1 `$ENV`:2 `$ENV`:3 `$ENV`:4 `$ENV`:5 `$ENV`:6 `$ENV`:7 `$ENV`:8 `$ENV`:9"
                $ENCODED = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($CONTENT))
                $NEWPATH = [IO.Path]::ChangeExtension($Path, ".bat")
                "@echo off`nsetlocal`nset 1=%~1`nset 2=%~2`nset 3=%~3`nset 4=%~4`nset 5=%~5`nset 6=%~6`nset 7=%~7`nset 8=%~8`nset 9=%~9`npowershell.exe -NOP -EP ByPass -Enc $ENCODED" | Set-Content -Path $NEWPATH -Encoding ASCII
                $COUNTCONVERTED++
                Write-Output "Converted $Path`: $NEWPATH written."
            }
            else
            { # other file type
                Write-Output "$Path is no Powershell script."
            }
        }
        else
        { # it is a directory or the file does not exist
            Write-Output "$Path is a directory or does not exist."
        }
}

    END
    { # report count of converted files
        Write-Output "$COUNTCONVERTED files converted."
    }
}


<#
.Synopsis
Compress log files older than the current month in a given directory or the IIS log directories.
.Description
Compress log files older than the current month in a given directory or the IIS log directories.
Zip archives with the name ZipArchiveYYYY.zip are created in the log directories, where YYYY is the year of change of the archived file.
By default, only files with the extension ".log" are archived. This extension, the month, the archive name and recursive processing of subdirectories can be selected by parameters.

A regular start via scheduled tasks can be set up at a command prompt for example via:

schtasks.exe /Create /TN "Archive IIS log files" /TR "Powershell.exe -NoProfile -Command \"Compress-LogDirectory -IIS\"" /SC MONTHLY /D 15 /ST 21:15 /RU SYSTEM /RL HIGHEST /F
.Parameter Path
Path of the log directory (also via pipeline)
.Parameter IIS
IIS log directories are processed
.Parameter Filter
Filter of the files to be archived
.Parameter MonthBack
Number of months in the past for checking the change date
.Parameter ArchiveName
Name part of the archives
.Parameter Recurse
Recursive processing of subdirectories of $Path
.Inputs
Directory path
.Outputs
None
.Example
Compress-LogFileDirectory -Path "C:\LogFiles" -Filter "*.*" -MonthBack 3 -ArchiveName "zip"

Archives all files in directory C:\LogFiles which are 3 months older than the current month in the archives "zipYYYY.zip" (YYYY = year of change of the respective file).
.Example
Compress-LogFileDirectory -IIS

Archives all files in IIS log directories older than the current month in the archives "ZipArchiveYYYY.zip" (YYYY = year of change of the respective file) in the log directories.
.Notes
Author: Markus Scholtes
Version: 1.0
Date: 2019-05-06
#>
function Compress-LogDirectory
{ Param([Parameter(Position=1,Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName="PerPath")][Alias("FullName")]$Path,
        [Parameter(Position=1,Mandatory,ParameterSetName="ForIIS")][SWITCH]$IIS,
        [Parameter(Position=2,ParameterSetName="PerPath")][STRING]$Filter = "*.log",
        [Parameter(Position=3,ParameterSetName="PerPath")][Parameter(Position=2,ParameterSetName="ForIIS")][INT]$MonthBack = 0,
        [Parameter(Position=4,ParameterSetName="PerPath")][Parameter(Position=3,ParameterSetName="ForIIS")][STRING]$ArchiveName = "ZipArchive",
        [Parameter(Position=5,ParameterSetName="PerPath")][SWITCH]$Recurse
    )

    function Compress-LogDirectory
    { # directory names can be passed per parameter or pipeline
        Param(
            [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)][Alias("FullName")]$Path,
            [STRING]$Filter = "*.log",
            [INT]$MonthBack = 0,
            [STRING]$ArchiveName = "ZipArchive"
        )

        # compute the date of the first day after the month to archive
        $DateBack = (Get-Date).AddMonths(-1*$MonthBack)
        $DateFilter = [DateTime]::new($DateBack.Year, $DateBack.Month, 1)

        Write-Output ("-"*80)
        # process only if path is a directory
        if (Test-Path -Path $Path -PathType Container)
        {
            if ($Path -is [STRING])
            { # if path is of type string, convert to DirectoryInfo
                $Path = Get-Item -Path $Path
            }

            Write-Output "Processing directory $($Path.FullName)"
            # retrieve filtered files older then $DateFilter
            $FILES = Get-ChildItem -Path $Path -Filter $Filter -File | Where-Object { $_.LastWriteTime -lt $DateFilter }
            if ($FILES.Count -gt 0)
            { # if files found fitting to filter
                Write-Output "Found $($FILES.Count) files to compress."
                $FILES | ForEach-Object { # for each file: compute archive name to last write time, add file to archive and delete file
                    try {
                        $NAMEWITHYEAR = Join-Path -Path $Path.FullName -ChildPath "$ArchiveName$($_.LastWriteTimeUtc.Year.ToString()).zip"

                        if ($_.FullName -ne $NAMEWITHYEAR)
                        { # only compress if not archive file itself
                            Write-Output "Compressing file $($_.Name) to archive $NAMEWITHYEAR"
                            Compress-Archive -Path $_.FullName -DestinationPath $NAMEWITHYEAR -Update:(Test-Path $NAMEWITHYEAR) -CompressionLevel Optimal -ErrorAction Stop

                            Write-Output "Removing file $($_.Name)"
                            Remove-Item -Path $_.FullName
                        }
                        else
                        { # archive file itself is ignored
                            Write-Output "Ignoring archive file $NAMEWITHYEAR"
                        }
                    }
                    catch { # error occured on archiving or deleting
                        Write-Error $PSItem.Exception.Message
                    }
                }
            }
            else
            { # no files to archive found
                Write-Output "Found no files to compress."
            }
        }
        else
        {   # file found or path does not exist, error and return
            if (Test-Path -Path $Path)
            { # file found
                Write-Error "$Path is a file."
            }
            else
            { # path does not exist
                Write-Error "$Path does not exist."
            }
        }
    }


    if ($IIS)
    { # process IIS logfile directories
        try { # load IIS module
            Import-Module WebAdministration -ErrorAction Stop
        }
        catch { # cannot load IIS module
            Write-Error "Cannot load IIS Powershell module, are IIS and administrative rights present?"
            return
        }

        ForEach ($WEBSITE in (Get-Website))
        { # iterate through websites
            $IISLOGDIR = $WEBSITE.LogFile.Directory + "\W3SVC" + $WEBSITE.Id -replace "%SystemDrive%", $ENV:SystemDrive -replace "%LOGFILEDIR%", $ENV:LOGFILEDIR
            Write-Output "Processing log directory $IISLOGDIR of web site '$($WEBSITE.Name)'"
            Compress-LogDirectory -Path $IISLOGDIR -Filter "*.log" -MonthBack $MonthBack -Archive $ArchiveName
        }
    }
    else
    { # process directory in parameter -Path
        # archive logs in directory $Path
        Compress-LogDirectory -Path $Path -Filter $Filter -MonthBack $MonthBack -Archive $ArchiveName

        if ($RECURSE)
        { # archive logs in subdirectories too
            Get-ChildItem -Path $Path -Directory -Recurse | ForEach-Object { Compress-LogDirectory -Path $_.FullName -Filter $Filter -MonthBack $MonthBack -Archive $ArchiveName }
        }
    }
}