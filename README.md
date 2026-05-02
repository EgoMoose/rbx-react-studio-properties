<!-- Links -->

[react-studio-properties/wally]: https://wally.run/package/egomoose/react-studio-properties

<!-- Badges -->

[badges/wally]: https://raw.githubusercontent.com/gist/cxmeel/0dbc95191f239b631c3874f4ccf114e2/raw/wally.svg

# rbx-react-studio-properties

[![Get it on Wally][badges/wally]][react-studio-properties/wally]

React implementations of Roblox Studio properties.

Components are close to 1:1 with Roblox, but have a few very minor deviations.

https://github.com/user-attachments/assets/6bdb047e-8d56-4057-aa74-726bbda23b95

## Studio Components

This package is heavily inspired by [StudioComponents](https://github.com/sircfenner/StudioComponents) and actually uses it internally for a number of components. It is highly recommended for best visual continuity to use this package alongside that one.

## Plugin Context

In order for the color picker widget to appear when using the Color3 property component you will need to provide plugin context:

```luau
return React.createElement(StudioProperties.PluginContext.Provider, {
	value = plugin,
}, {
	Component1 = ...,
	Component2 = ...,
	...
})
```