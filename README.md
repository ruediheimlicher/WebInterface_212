# WebInterface_212
Interface zu HomeCentral mit https

WebInterface
 - Webserver(RaspberryPi mit flask-Webserver, RaspberryPi Z als ReverseProxy mit nGinx)
 - - HomeCentral als TWI/I2C-Master via soft-SPI vom WebServer (48 Byte)
 - - - Slaves via TWI/I2C
