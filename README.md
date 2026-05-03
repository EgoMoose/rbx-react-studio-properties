<!-- Links -->

[react-studio-properties/releases]: https://github.com/EgoMoose/rbx-react-studio-properties/releases
[react-studio-properties/wally]: https://wally.run/package/egomoose/react-studio-properties

<!-- Badges -->

[badges/github]: https://raw.githubusercontent.com/gist/cxmeel/0dbc95191f239b631c3874f4ccf114e2/raw/github.svg
[badges/wally]: https://raw.githubusercontent.com/gist/cxmeel/0dbc95191f239b631c3874f4ccf114e2/raw/wally.svg

# rbx-react-studio-properties

[![Get it on Github][badges/github]][react-studio-properties/releases] [![Get it on Wally][badges/wally]][react-studio-properties/wally]

React implementations of Roblox Studio properties.

Components are close to 1:1 with Roblox, but have a few very minor deviations.

<img width="200" alt="AfnxIljnJD" src="https://github.com/user-attachments/assets/f344ca4a-2e13-4b98-ada7-4012435e8ea5" /> <img width="300" alt="RobloxStudioBeta_TSfCA7Qtig" src="https://github.com/user-attachments/assets/29092ec9-6970-42e4-8f61-85dd420bc298" />

https://github.com/user-attachments/assets/11703415-e14e-4cb2-9e51-77ec55c3ba78

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
