# RabbitMQ.app

### The easiest way to get started with RabbitMQ on the Mac

*Just download, drag to the applications folder, and double-click.*

![Screenshot](https://jpadilla.github.io/rabbitmqapp/assets/img/screenshot.png)

### [Download](http://jpadilla.github.io/rabbitmqapp)

--

### Version numbers

Version numbers of this project (RabbitMQ.app) try to communicate the version of the included RabbitMQ binaries bundled with each release.

The version number also includes a build number which is used to indicate the current version of RabbitMQ.app and it's independent from the bundled RabbitMQ's version.

### Adding RabbitMQ binaries to your path

If you need to add the RabbitMQ binaries to your path you can do so by adding the following to your `~/.bash_profile`.

```bash
# Add RabbitMQ.app binaries to path
PATH="/Applications/RabbitMQ.app/Contents/Resources/Vendor/rabbitmq/sbin:$PATH"
```

Or using the `path_helper` alternative:
 
 ```bash
sudo mkdir -p /etc/paths.d &&
echo /Applications/RabbitMQ.app/Contents/Resources/Vendor/rabbitmq/sbin | sudo tee /etc/paths.d/rabbitmqapp
 ```

### Installing with Homebrew Cask

You can also install RabbitMQ.app with [Homebrew Cask](https://formulae.brew.sh/cask/jpadilla-rabbitmq#default).

```bash
$ brew install --cask jpadilla-rabbitmq
```

### Credits

Forked and adapted from [Mongodb.app](https://github.com/gcollazo/mongodbapp). Site design by [Giovanni Collazo](https://twitter.com/gcollazo).
