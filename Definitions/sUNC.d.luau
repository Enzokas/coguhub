-- Generated automatically from sUNC documentation.
-- Do not edit manually.

-- Types
export type FunctionFilterOptions = {
    Name: string?,
    IgnoreExecutor: boolean?,
    Hash: string?,
    Constants: { any }?,
    Upvalues: { any }?
}
export type TableFilterOptions = {
    Keys: { [any]: any }?,
    Values: { [any]: any }?,
    KeyValuePairs: { [any]: any }?,
    Metatable: { [any]: any }?
}
export type Connection = {
    Enabled: boolean,
    ForeignState: boolean,
    LuaConnection: boolean,
    Function: ((...any) -> (...any))?,
    Thread: thread?,

    Fire: (self: Connection, ...any) -> (),
    Defer: (self: Connection, ...any) -> (),
    Disconnect: (self: Connection) -> (),
    Disable: (self: Connection) -> (),
    Enable: (self: Connection) -> ()
}
export type Drawing = {
    Visible: boolean,
    ZIndex: number,
    Transparency: number,
    Color: Color3,
    __OBJECT_EXISTS: boolean,

    Destroy: (self: Drawing) -> ()
}
export type AnyFunction = (...any) -> (...any)
export type AnyTable = { [any]: any }
export type userdata = typeof(newproxy()) -- (1)
export type RequestOptions = {
    Url: string,
    Method: "GET" | "HEAD" | "POST" | "PUT" | "DELETE" | "OPTIONS" | "PATCH",
    Body: string?,
    Headers: { [string]: string }?,
    Cookies: { [string]: string }?
}
export type Response = {
    Success: boolean,
    Body: string,
    StatusCode: number,
    StatusMessage: string,
    Headers: { [string]: string }
}

-- Declarations
declare getgc:
    ((includeTables: true) -> { AnyTable | AnyFunction | userdata }) &
    ((includeTables: false?) -> { AnyFunction | userdata })
declare function getreg(): { [any]: any }
declare filtergc:
    (( filterType: "function", filterOptions: FunctionFilterOptions, returnOne: true) -> AnyFunction? ) &
    ((( filterType: "function", filterOptions: FunctionFilterOptions, returnOne: false?) -> ( AnyFunction | { AnyFunction } ) )) &
    (( filterType: "table", filterOptions: TableFilterOptions, returnOne: true) -> { AnyTable? } ) &
    (( filterType: "table", filterOptions: TableFilterOptions, returnOne: false? ) -> { AnyTable })
declare function getgenv(): { any }
declare function getrenv(): { any }
declare function getscripthash(script: BaseScript | ModuleScript): string | nil
declare function getscripts(): { BaseScript | ModuleScript }
declare function getsenv(script: BaseScript | ModuleScript): { [any]: any } | nil
declare function getrunningscripts(): { BaseScript | ModuleScript }
declare function getloadedmodules(): { ModuleScript }
declare function getscriptbytecode(script: BaseScript | ModuleScript): string | nil
declare function getscriptfromthread(thread: thread): BaseScript | ModuleScript | nil
declare function getcallingscript(): BaseScript | ModuleScript | nil
declare function getscriptclosure(script: BaseScript | ModuleScript): ((...any) -> (...any))?
declare function getnamecallmethod(): string?
declare function isreadonly(table: { any }): boolean
declare function getrawmetatable(object: { any } | userdata): { [any]: any } | nil
declare function setrawmetatable<T>(object: T & ({ any } | userdata), metatable: { any }): T
declare function setreadonly(table: { any }, state: boolean): ()
declare function gethiddenproperty(object: Object, property_name: string): (any, boolean)
declare function sethiddenproperty(object: Object, property_name: string, property_value: any): boolean
declare function setthreadidentity(id: number): ()
declare function getthreadidentity(): number
declare function isscriptable(object: Object, property: string): boolean | nil
declare function setscriptable(object: Object, property_name: string, state: boolean): boolean | nil
declare function replicatesignal(signal: RBXScriptSignal, ...: any?)
declare function getconnections(signal: RBXScriptSignal): {Connection}
declare function firesignal(signal: RBXScriptSignal, ...: any?)
declare function cleardrawcache(): ()
declare function isrenderobj(object: any): boolean
declare function getrenderproperty(drawing: Drawing, property: string): any
declare function setrenderproperty(drawing: Drawing, property: string, value: any): ()
declare function getcustomasset(path: string): string
declare function makefolder(path: string): ()
declare function isfile(path: string): boolean
declare function delfile(path: string): ()
declare function loadfile<A...>(path: string): ((A...) -> any | nil, string?)
declare function writefile(path: string, data: string): ()
declare function isfolder(path: string): boolean
declare function listfiles(path: string): { string }
declare function delfolder(path: string): ()
declare function readfile(path: string): string
declare function appendfile(path: string, contents: string): ()
declare function identifyexecutor(): (string, string)
declare function request(options: RequestOptions): Response
declare function cloneref<T>(object: T & Instance): T
declare function fireclickdetector(detector: ClickDetector, distance: number?, event: string?): ()
declare function fireproximityprompt(prompt: ProximityPrompt): ()
declare function gethui(): BasePlayerGui | Folder
declare function compareinstances(object1: Instance, object2: Instance): boolean
declare function getcallbackvalue(object: Object, property: string): any | nil
declare function getnilinstances(): { Instance }
declare function getinstances(): { Instance }
declare function firetouchinterest(part1: BasePart, part2: BasePart, toggle: boolean | number): ()
declare function base64encode(data: string): string
declare function lz4compress(data: string): string
declare function base64decode(data: string): string
declare function lz4decompress(data: string): string
declare function newcclosure<A..., R...>(functionToWrap: (A...) -> R...): (A...) -> R...
declare function clonefunction<A..., R...>(functionToClone: (A...) -> R...): (A...) -> R...
declare function restorefunction(functionToRestore: (...any) -> (...any)): ()
declare function isexecutorclosure(func: (...any) -> (...any)): boolean
declare function islclosure(func: (...any) -> (...any)): boolean
declare function iscclosure(func: (...any) -> (...any)): boolean
declare function loadstring<A...>(source: string, chunkname: string?): (((A...) -> any) | nil, string?)
declare function getfunctionhash(functionToHash: (...any) -> (...any)): string
declare function checkcaller(): boolean
declare function hookmetamethod(object: { [any]: any } | Object | userdata, metamethodName: string, hook: (...any) -> (...any)): (...any) -> (...any)
declare function hookfunction<A1..., R1..., A2..., R2...>(functionToHook: (A1...) -> R1..., hook: (A2...) -> R2...): (A1...) -> R1...

-- Namespaced libraries
declare debug: {
    getproto: (func: (...any) -> (...any) | number, index: number, activated: boolean?) -> (...any) -> (...any) | { (...any) -> (...any) },
    getconstants: (func: (...any) -> (...any) | number) -> { number | string | boolean | nil },
    getprotos: (func: (...any) -> (...any) | number) -> { (...any) -> (...any) },
    setstack: (level: number, index: number, value: any) -> (),
    getconstant: (func: (...any) -> (...any) | number, index: number) -> number | string | boolean | nil,
    getupvalue: (func: (...any) -> (...any) | number, index: number) -> any,
    getupvalues: (func: (...any) -> (...any) | number) -> { any },
    setupvalue: (func: (...any) -> (...any) | number, index: number, value: any) -> (),
    setconstant: (func: (...any) -> (...any) | number, index: number, value: number | string | boolean | nil) -> (),
    getstack: (level: number, index: number?) -> any | { any },
}
