## Image hardening descriptor

Begin with a base ** alpine linux image ** 
  > the image foot print is small avaiding any unnecesary packages

Adopt a multi-stage docker build strategy
  > Divide the image creation steps into different build stages copying over only what is needed to the next step

Use non-root users

Image Scanning to ensure that known vulnerabilities are not included in the inage
