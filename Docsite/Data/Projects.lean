/-
  Docsite.Data.Projects - Project data for all 66 workspace projects
-/

namespace Docsite.Data.Projects

/-- A section within project documentation -/
structure DocSection where
  title : String
  content : String  -- HTML content
  deriving Repr, BEq

/-- Rich documentation for a project -/
structure ProjectDoc where
  overview : String       -- Main description/intro (HTML)
  installation : String   -- Installation instructions (HTML)
  quickStart : String     -- Quick start code example (HTML)
  sections : List DocSection  -- Additional documentation sections
  deriving Repr, BEq

/-- A project in the workspace -/
structure Project where
  name : String
  slug : String
  category : String
  categorySlug : String
  description : String
  documentation : Option ProjectDoc := none  -- Optional rich docs
  deriving Repr, BEq

/-- All project categories -/
def categories : List (String × String) := [
  ("Graphics", "graphics"),
  ("Web", "web"),
  ("Network", "network"),
  ("Data", "data"),
  ("Apps", "apps"),
  ("Util", "util"),
  ("Math", "math"),
  ("Audio", "audio"),
  ("Testing", "testing")
]

/-- Documentation for the Reactive FRP library -/
def reactiveDoc : ProjectDoc := {
  overview := "
<p>Reactive is a <strong>Reflex-style Functional Reactive Programming (FRP)</strong> library for Lean 4.
It provides a declarative way to work with time-varying values and discrete events,
enabling you to build reactive systems with clean, composable abstractions.</p>

<h3>Key Features</h3>
<ul>
  <li><strong>Push/Pull Hybrid Model</strong> - Events are push-based for efficiency, Behaviors are pull-based for consistency</li>
  <li><strong>Timeline Phantom Types</strong> - Type-safe separation of reactive networks prevents accidental cross-timeline operations</li>
  <li><strong>Glitch-Free Propagation</strong> - Height-based topological ordering ensures consistent state during updates</li>
  <li><strong>Frame-Based Updates</strong> - All events in a frame are processed atomically, preventing intermediate states</li>
  <li><strong>Automatic Subscription Management</strong> - Scoped subscriptions with hierarchical cleanup</li>
</ul>
"

  installation := "
<p>Add Reactive to your <code>lakefile.lean</code>:</p>
<pre><code class=\"language-lean\">require reactive from git \"https://github.com/nathanial/reactive\" @ \"v0.0.1\"</code></pre>

<p>Then import in your Lean files:</p>
<pre><code class=\"language-lean\">import Reactive

open Reactive
open Reactive.Host</code></pre>
"

  quickStart := "
<p>Here's a simple counter that tracks button clicks:</p>
<pre><code class=\"language-lean\">import Reactive

open Reactive
open Reactive.Host

def counterExample : SpiderM Unit := do
  -- Create a triggerable event for button clicks
  let (clickEvent, fireClick) ← newTriggerEvent

  -- Fold over clicks to maintain a count
  let clickCount ← foldDyn (fun _ n => n + 1) 0 clickEvent

  -- Subscribe to see count changes
  let _ ← clickCount.updated.subscribe fun n =>
    IO.println s!\"Click count: {n}\"

  -- Simulate some clicks
  fireClick ()  -- prints \"Click count: 1\"
  fireClick ()  -- prints \"Click count: 2\"
  fireClick ()  -- prints \"Click count: 3\"

def main : IO Unit := do
  runSpider counterExample</code></pre>

<p>The key insight is that <code>foldDyn</code> creates a <code>Dynamic</code> that automatically
updates whenever the source event fires, and we can observe those changes through <code>.updated</code>.</p>
"

  sections := [
    { title := "Core Types"
      content := "
<p>Reactive is built on three fundamental abstractions that together model all aspects of time-varying
computation: <strong>Event</strong> for discrete occurrences, <strong>Behavior</strong> for continuous
values, and <strong>Dynamic</strong> for stateful values that change and notify observers. Understanding
when and how to use each type is essential for building correct reactive systems.</p>

<p>These types follow a <strong>push/pull hybrid model</strong>. Events are push-based—when something happens,
the change propagates through the network automatically. Behaviors are pull-based—you sample them when you
need a value, and they compute it on demand. Dynamics combine both: they maintain current state you can
sample (pull) while also pushing change notifications to subscribers.</p>

<p>Each type carries a phantom type parameter <code>t</code> representing the timeline. This ensures type
safety at compile time: you cannot accidentally mix events or behaviors from different reactive networks.
The concrete timeline used in practice is <code>Spider</code>, an IO-based push runtime.</p>

<h3>Event — Discrete Occurrences</h3>

<p><code>Event t a</code> represents discrete occurrences over time. Think of it as a stream of values that
fire at specific moments—user clicks, key presses, network responses, timer ticks, or any other momentary
happening. Conceptually, an Event is a sparse timeline: <code>[(Time, a)]</code>—a list of time/value
pairs where most times have no value.</p>

<p>Events are <strong>push-based</strong>. When an event fires, its value propagates through all derived
events and subscribers automatically. You don't poll events; you subscribe to them or derive new events
from them, and the system notifies you when something happens.</p>

<h4>Internal Structure</h4>

<p>Under the hood, each Event is backed by an <code>EventNode</code> containing:</p>
<ul>
  <li><strong>nodeId</strong> — Unique identifier for ordering and debugging</li>
  <li><strong>height</strong> — Topological depth used for glitch-free propagation</li>
  <li><strong>subscribers</strong> — Array of callback functions to invoke when the event fires</li>
  <li><strong>lazy deletion</strong> — Unsubscribed callbacks are marked and cleaned up lazily</li>
</ul>

<p>The height system ensures that when multiple events fire in response to a single trigger, they process
in dependency order. A derived event always has height greater than its sources, so parents fire before
children. This prevents glitches where a subscriber might see inconsistent intermediate states.</p>

<h4>Creating Events</h4>

<p>The primary way to create an event you can fire programmatically is <code>newTriggerEvent</code>:</p>

<pre><code class=\"language-lean\">-- Returns the event and a trigger function
let (clickEvent, fireClick) ← newTriggerEvent

-- Fire the event with a value
fireClick \"button-1\"  -- All subscribers receive \"button-1\"</code></pre>

<p>The trigger function runs in <code>IO</code>, not <code>SpiderM</code>, so you can call it from anywhere—
event handlers, callbacks, external integrations. Each call fires the event in a new frame, processing
all propagations atomically before returning.</p>

<h4>Key Combinators</h4>

<p><strong>Transformation:</strong> <code>mapM</code>, <code>filterM</code>, and <code>mapMaybeM</code>
transform event values. Successive maps fuse into a single function internally for efficiency.</p>

<pre><code class=\"language-lean\">let doubled ← Event.mapM (· * 2) numbers
let positives ← Event.filterM (· > 0) numbers
let parsed ← Event.mapMaybeM String.toNat? inputs</code></pre>

<p><strong>Combining:</strong> <code>mergeM</code> combines two event streams; when both fire simultaneously,
the first wins. <code>mergeListM</code> and <code>leftmostM</code> extend this to multiple events.</p>

<pre><code class=\"language-lean\">let anyClick ← Event.mergeM buttonClick keyPress
let firstResponse ← Event.leftmostM [server1, server2, server3]</code></pre>

<p><strong>Behavior Interaction:</strong> Events often need to read current state when they fire.
<code>tagM</code> samples a behavior and replaces the event value. <code>attachM</code> pairs the
behavior value with the event value. <code>gateM</code> filters events based on a boolean behavior.</p>

<pre><code class=\"language-lean\">-- On click, capture current mouse position
let clickPos ← Event.tagM mousePosition clickEvent

-- Pair click with current modifier keys
let clickWithMods ← Event.attachM modifierKeys clickEvent

-- Only allow clicks when not dragging
let allowedClicks ← Event.gateM (Behavior.map not isDragging) clickEvent</code></pre>

<p><strong>Stateful:</strong> <code>accumulateM</code> folds over events, emitting accumulated values.
<code>distinctM</code> suppresses consecutive duplicate values (requires <code>BEq</code>).</p>

<pre><code class=\"language-lean\">let runningSum ← Event.accumulateM (· + ·) 0 numbers
let changes ← Event.distinctM mousePosition  -- Only fire on actual movement</code></pre>

<p><strong>Timing:</strong> <code>zipEM</code> pairs events that fire simultaneously (useful for
coordination). <code>differenceM</code> fires the first event only when the second doesn't fire.
<code>delayFrameM</code> defers an event to the next frame.</p>

<h4>Subscription</h4>

<p>To observe an event, use <code>subscribe</code>:</p>

<pre><code class=\"language-lean\">let unsub ← clickEvent.subscribe fun value => do
  IO.println s!\"Clicked: {value}\"

-- Later, to stop receiving events:
unsub</code></pre>

<p>In <code>SpiderM</code> context, subscriptions are automatically registered with the current scope
and cleaned up when the scope is disposed.</p>

<h3>Behavior — Time-Varying Values</h3>

<p><code>Behavior t a</code> represents a value that varies continuously over time. Unlike events which
fire at discrete moments, a behavior always has a current value—you can sample it at any time.
Conceptually, a Behavior is a function from time to value: <code>Time → a</code>.</p>

<p>Behaviors are <strong>pull-based</strong>. They don't push updates; instead, you ask for the current
value when you need it. This makes them ideal for values that change frequently or continuously (like
mouse position) where you only care about the value at specific moments (like when a click occurs).</p>

<h4>Internal Structure</h4>

<p>A Behavior is essentially a wrapped sampling action: <code>IO a</code>. When you sample a behavior,
it computes and returns the current value. For simple behaviors this might read a reference; for derived
behaviors it might compute from other behaviors. There's no caching—each sample recomputes, which
ensures you always get the current value.</p>

<h4>Creating Behaviors</h4>

<p><code>constant</code> creates a behavior that always returns the same value. <code>fromSample</code>
wraps an arbitrary IO action as a behavior. <code>hold</code> creates a behavior from an initial value
and an event that updates it.</p>

<pre><code class=\"language-lean\">-- Always returns 42
let answer ← Behavior.constant 42

-- Samples current system time on each access
let now ← Behavior.fromSample IO.monoMsNow

-- Starts at 0, updates to each event value
let lastClick ← Behavior.hold 0 clickPositions</code></pre>

<h4>Key Combinators</h4>

<p>Behavior implements <code>Functor</code>, <code>Applicative</code>, and <code>Monad</code>, enabling
familiar functional composition:</p>

<pre><code class=\"language-lean\">-- Functor: transform values
let doubled ← Behavior.map (· * 2) counter

-- Applicative: combine independent behaviors
let sum ← Behavior.zipWith (· + ·) countA countB

-- Monad: dynamic behavior selection
let currentPage ← Behavior.bind pageIndex (pages.get!)</code></pre>

<p><strong>Combining:</strong> <code>zipWith</code>, <code>zip</code>, and <code>zipWith3</code> combine
multiple behaviors. <code>allTrue</code> and <code>anyTrue</code> work on lists of boolean behaviors.
Boolean operations <code>not</code>, <code>and</code>, <code>or</code> compose boolean behaviors.</p>

<p><strong>Higher-order:</strong> <code>switch</code> flattens a <code>Behavior (Behavior a)</code>
into <code>Behavior a</code>, dynamically switching which inner behavior is sampled based on the
outer behavior's current value.</p>

<h4>Sampling</h4>

<p>Use <code>sample</code> to read a behavior's current value:</p>

<pre><code class=\"language-lean\">let pos ← sample mousePosition
IO.println s!\"Mouse at: {pos}\"</code></pre>

<p>Sampling is synchronous and returns immediately with the current value.</p>

<h4>When to Use Behavior</h4>

<p>Use Behavior when you have a continuously available value that you need to read on demand:
mouse position, current window size, computed values derived from other behaviors, configuration
that rarely changes. If you also need to know <em>when</em> the value changes, use Dynamic instead.</p>

<h3>Dynamic — The Best of Both Worlds</h3>

<p><code>Dynamic t a</code> combines the capabilities of Behavior and Event. It maintains a current
value you can sample at any time (like Behavior), while also providing an event that fires whenever
the value changes (like Event). This makes it the primary choice for application state.</p>

<p>A Dynamic provides two access patterns through its fields:</p>
<ul>
  <li><code>.current</code> — A <code>Behavior t a</code> for sampling the current value</li>
  <li><code>.updated</code> — An <code>Event t a</code> that fires with the new value on each change</li>
</ul>

<h4>Internal Structure</h4>

<p>Internally, a Dynamic contains:</p>
<ul>
  <li><strong>valueRef</strong> — An <code>IO.Ref a</code> holding the current value</li>
  <li><strong>updateEvent</strong> — An <code>Event t a</code> that fires on changes</li>
  <li><strong>trigger</strong> — Function to update the value and fire the event atomically</li>
</ul>

<p>When you update a Dynamic, both the reference and the event update in a single atomic action.
This ensures observers never see the reference and event out of sync.</p>

<h4>Creating Dynamics</h4>

<p><code>holdDyn</code> creates a Dynamic that holds the most recent event value:</p>

<pre><code class=\"language-lean\">let lastInput ← holdDyn \"\" inputEvents
-- Initially \"\", updates to each new input value</code></pre>

<p><code>foldDyn</code> folds over events to accumulate state:</p>

<pre><code class=\"language-lean\">let counter ← foldDyn (fun _ n => n + 1) 0 clicks
-- Starts at 0, increments on each click</code></pre>

<h4>Key Combinators</h4>

<p><strong>Mapping:</strong> <code>mapM</code> transforms Dynamic values. Note that it does <em>not</em>
deduplicate—if the source fires with the same value, the mapped Dynamic fires too.</p>

<pre><code class=\"language-lean\">let doubled ← Dynamic.mapM (· * 2) counter</code></pre>

<p><strong>Deduplication:</strong> <code>mapUniqM</code> adds deduplication using <code>BEq</code>.
The derived Dynamic only fires when the mapped value actually changes.</p>

<pre><code class=\"language-lean\">-- Only fires when parity changes, not on every increment
let isEven ← Dynamic.mapUniqM (· % 2 == 0) counter</code></pre>

<p>This distinction matters for performance and correctness. Use <code>mapM</code> when every source
update matters; use <code>mapUniqM</code> when you only care about distinct values.</p>

<p><strong>Combining:</strong> <code>zipWithM</code> and <code>zipWith3M</code> combine multiple Dynamics:</p>

<pre><code class=\"language-lean\">let total ← Dynamic.zipWithM (· + ·) countA countB
-- Updates whenever either input changes</code></pre>

<p><strong>Switching:</strong> <code>switchM</code> flattens <code>Dynamic (Dynamic a)</code> into
<code>Dynamic a</code>. When the outer Dynamic changes, the result switches to tracking the new
inner Dynamic.</p>

<pre><code class=\"language-lean\">let currentTab ← Dynamic.switchM selectedTabDynamic
-- Tracks whichever Dynamic is currently selected</code></pre>

<p><strong>Changes:</strong> <code>changesM</code> gives you <code>(old, new)</code> pairs on each update,
useful when you need to know what changed:</p>

<pre><code class=\"language-lean\">let transitions ← Dynamic.changesM counter
-- Fires (0, 1), then (1, 2), etc.</code></pre>

<h4>When to Use Dynamic</h4>

<p>Use Dynamic for application state that:</p>
<ul>
  <li>Changes over time in response to events</li>
  <li>Needs to be read synchronously (e.g., to render current UI state)</li>
  <li>Has observers that need change notifications (e.g., to re-render on updates)</li>
</ul>

<p>Most interactive application state is best modeled as Dynamic. Use plain Events for fire-and-forget
notifications and plain Behaviors for computed values you only need to sample.</p>

<h3>Type Safety with Timeline Phantom Types</h3>

<p>Every Event, Behavior, and Dynamic carries a phantom type parameter <code>t</code> representing
its timeline. This type parameter appears in the type signature but has no runtime representation—it
exists purely for compile-time safety.</p>

<pre><code class=\"language-lean\">def Event (t : Type) (a : Type) : Type := ...
def Behavior (t : Type) (a : Type) : Type := ...
def Dynamic (t : Type) (a : Type) : Type := ...</code></pre>

<p>The <code>Spider</code> timeline is the concrete IO-based implementation you use in practice.
When you work within <code>SpiderM</code>, all your events, behaviors, and dynamics share the same
<code>Spider</code> timeline type.</p>

<p>The phantom type prevents accidentally mixing values from different reactive networks. If you
somehow had two separate Spider runtimes (unusual, but possible), their events couldn't be combined—
the type checker would reject it. This catches a class of bugs at compile time that would otherwise
cause subtle runtime issues.</p>

<p>After <code>open Reactive.Host</code>, you get convenient type aliases:</p>
<ul>
  <li><code>Evt a</code> = <code>Event Spider a</code></li>
  <li><code>Beh a</code> = <code>Behavior Spider a</code></li>
  <li><code>Dyn a</code> = <code>Dynamic Spider a</code></li>
</ul>

<p>These aliases are used throughout the API for conciseness while maintaining full type safety.</p>
" },
    { title := "Event Combinators"
      content := "
<p>Events can be transformed and combined using a rich set of combinators. All SpiderM variants
automatically manage subscriptions and node IDs.</p>

<table class=\"api-table\">
  <thead>
    <tr><th>Combinator</th><th>Type</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr><td><code>Event.mapM f e</code></td><td><code>(a → b) → Evt a → SpiderM (Evt b)</code></td><td>Transform each value</td></tr>
    <tr><td><code>Event.filterM p e</code></td><td><code>(a → Bool) → Evt a → SpiderM (Evt a)</code></td><td>Keep values matching predicate</td></tr>
    <tr><td><code>Event.mapMaybeM f e</code></td><td><code>(a → Option b) → Evt a → SpiderM (Evt b)</code></td><td>Filter + transform</td></tr>
    <tr><td><code>Event.mergeM e1 e2</code></td><td><code>Evt a → Evt a → SpiderM (Evt a)</code></td><td>Combine two event streams</td></tr>
    <tr><td><code>Event.tagM b e</code></td><td><code>Beh a → Evt b → SpiderM (Evt a)</code></td><td>Sample behavior on event</td></tr>
    <tr><td><code>Event.attachM b e</code></td><td><code>Beh a → Evt c → SpiderM (Evt (a × c))</code></td><td>Pair behavior with event</td></tr>
    <tr><td><code>Event.gateM b e</code></td><td><code>Beh Bool → Evt a → SpiderM (Evt a)</code></td><td>Pass events only when behavior is true</td></tr>
    <tr><td><code>Event.accumulateM f init e</code></td><td><code>(a → b → b) → b → Evt a → SpiderM (Evt b)</code></td><td>Running fold over events</td></tr>
    <tr><td><code>Event.distinctM e</code></td><td><code>[BEq a] → Evt a → SpiderM (Evt a)</code></td><td>Skip consecutive duplicates</td></tr>
    <tr><td><code>Event.zipEM e1 e2</code></td><td><code>Evt a → Evt b → SpiderM (Evt (a × b))</code></td><td>Pair simultaneous events</td></tr>
    <tr><td><code>Event.differenceM e1 e2</code></td><td><code>Evt a → Evt b → SpiderM (Evt a)</code></td><td>Fire e1 only when e2 doesn't</td></tr>
  </tbody>
</table>

<h4>Example: Filtered Counter</h4>
<pre><code class=\"language-lean\">-- Count only even numbers
let (numbers, fireNum) ← newTriggerEvent
let evens ← Event.filterM (· % 2 == 0) numbers
let evenCount ← foldDyn (fun _ n => n + 1) 0 evens</code></pre>
" },
    { title := "Dynamic Combinators"
      content := "
<p>Dynamics represent state that changes over time. They combine the sampling capability of
Behaviors with change notifications.</p>

<table class=\"api-table\">
  <thead>
    <tr><th>Combinator</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr><td><code>holdDyn init e</code></td><td>Create Dynamic holding latest event value</td></tr>
    <tr><td><code>foldDyn f init e</code></td><td>Fold over events to build state</td></tr>
    <tr><td><code>Dynamic.mapM f d</code></td><td>Transform Dynamic values (no dedup)</td></tr>
    <tr><td><code>Dynamic.mapUniqM f d</code></td><td>Transform with BEq deduplication</td></tr>
    <tr><td><code>Dynamic.zipWithM f d1 d2</code></td><td>Combine two Dynamics</td></tr>
    <tr><td><code>Dynamic.switchM dd</code></td><td>Flatten <code>Dyn (Dyn a)</code> → <code>Dyn a</code></td></tr>
  </tbody>
</table>

<h4>Example: Derived State</h4>
<pre><code class=\"language-lean\">-- Two counters and their sum
let (incA, fireA) ← newTriggerEvent
let (incB, fireB) ← newTriggerEvent

let countA ← foldDyn (fun _ n => n + 1) 0 incA
let countB ← foldDyn (fun _ n => n + 1) 0 incB
let total ← Dynamic.zipWithM (· + ·) countA countB

-- total automatically updates when either counter changes</code></pre>
" },
    { title := "Frames and Glitch-Free Propagation"
      content := "
<p>Reactive uses <strong>frame-based propagation</strong> to ensure glitch-free updates. A \"glitch\"
occurs when a derived value sees inconsistent intermediate states during an update.</p>

<h4>How It Works</h4>
<ol>
  <li><strong>Height Assignment</strong> - Each event node has a height based on its dependencies. Derived nodes are always higher than their sources.</li>
  <li><strong>Priority Queue</strong> - When events fire, they're queued by (height, nodeId) in a binary min-heap.</li>
  <li><strong>Ordered Processing</strong> - Events are processed in height order, ensuring all dependencies fire before dependents.</li>
</ol>

<pre><code class=\"language-lean\">-- Example: Without glitch-free propagation, this could produce wrong results
let (input, fire) ← newTriggerEvent
let doubled ← Event.mapM (· * 2) input
let plusOne ← Event.mapM (· + 1) input
let combined ← Dynamic.zipWithM (·, ·) doubled plusOne

-- With glitch-free: When input fires 5, combined sees (10, 6) atomically
-- Without: combined might briefly see (10, oldValue) or (oldValue, 6)</code></pre>

<h4>Frame Boundaries</h4>
<p>All events fired by a single trigger are processed in the same frame. Use <code>delayFrameM</code>
to explicitly defer an event to the next frame.</p>
" },
    { title := "SpiderM Runtime"
      content := "
<p>The <code>Spider</code> timeline provides an IO-based push runtime for reactive networks.
<code>SpiderM</code> is the monad for building reactive computations.</p>

<h4>Key Operations</h4>
<pre><code class=\"language-lean\">-- Run a reactive network
runSpider : SpiderM a → IO a

-- Create triggerable events
newTriggerEvent : SpiderM (Evt a × (a → IO Unit))

-- Create state
holdDyn : a → Evt a → SpiderM (Dyn a)
foldDyn : (a → b → b) → b → Evt a → SpiderM (Dyn b)

-- Sample behaviors
sample : Beh a → SpiderM a</code></pre>

<h4>Type Aliases</h4>
<p>After <code>open Reactive.Host</code>:</p>
<ul>
  <li><code>Evt a</code> = <code>Event Spider a</code></li>
  <li><code>Beh a</code> = <code>Behavior Spider a</code></li>
  <li><code>Dyn a</code> = <code>Dynamic Spider a</code></li>
</ul>

<h4>Running with Event Loop</h4>
<pre><code class=\"language-lean\">-- Run with external event source
runSpiderLoop : SpiderM a → (Evt a) → (a → Bool) → IO Unit

-- Or manually control the loop
def myApp : SpiderM Unit := do
  let (quit, fireQuit) ← newTriggerEvent
  -- Set up reactive network...
  -- fireQuit () when done</code></pre>
" },
    { title := "Subscription Scopes"
      content := "
<p>Subscriptions are automatically managed through <code>SubscriptionScope</code>. When you create
derived events or dynamics in SpiderM, their subscriptions are registered with the current scope.</p>

<h4>Hierarchical Cleanup</h4>
<pre><code class=\"language-lean\">let scope ← SubscriptionScope.new

-- Register cleanup action
scope.register someUnsub

-- Create child scope (disposed when parent is disposed)
let child ← scope.child

-- Dispose all (children first, then parent's registrations)
scope.dispose</code></pre>

<p>SpiderM tracks a <code>currentScope</code> - all combinators automatically register their
subscriptions, so cleanup happens correctly when the scope is disposed.</p>

<h4>Best Practice</h4>
<p>Let SpiderM manage scopes automatically. Manual scope management is only needed for
advanced patterns like dynamically created/destroyed reactive subnetworks.</p>
" },
    { title := "Recursive Networks"
      content := "
<p>For circular dependencies between events/dynamics, Reactive provides fix-point combinators:</p>

<table class=\"api-table\">
  <thead>
    <tr><th>Combinator</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr><td><code>SpiderM.fixDynM f</code></td><td>Self-referential Dynamic via lazy Behavior</td></tr>
    <tr><td><code>SpiderM.fixDyn2M f</code></td><td>Mutually recursive Dynamic pair</td></tr>
    <tr><td><code>SpiderM.fixEventM f</code></td><td>Self-referential Event</td></tr>
  </tbody>
</table>

<h4>Example: Counter with Maximum</h4>
<pre><code class=\"language-lean\">-- Counter that stops at maxValue
let counter ← SpiderM.fixDynM fun counterBehavior => do
  let (clicks, fire) ← newTriggerEvent

  -- Gate clicks by whether we're below max
  let gated ← Event.gateM (counterBehavior.map (· < maxValue)) clicks

  -- Fold gated clicks into count
  foldDyn (fun _ n => n + 1) 0 gated</code></pre>

<p>The key is that <code>fixDynM</code> provides access to the Dynamic's <em>Behavior</em> (for sampling)
before the Dynamic is fully constructed. This enables self-reference without actual recursion.</p>
" },
    { title := "Async Patterns"
      content := "
<p>Reactive provides helpers for integrating with asynchronous IO operations:</p>

<table class=\"api-table\">
  <thead>
    <tr><th>Function</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr><td><code>asyncIO action</code></td><td>Run IO async, track as <code>Dyn (AsyncState e a)</code></td></tr>
    <tr><td><code>asyncOnEvent e action</code></td><td>Run async on each event (cancels previous)</td></tr>
    <tr><td><code>asyncWithRetry config action</code></td><td>Async with exponential backoff retry</td></tr>
    <tr><td><code>performEvent e</code></td><td>Run IO on event, return result event</td></tr>
    <tr><td><code>performEvent_ e</code></td><td>Run IO on event, discard result</td></tr>
  </tbody>
</table>

<h4>Example: Async Data Loading</h4>
<pre><code class=\"language-lean\">-- Load data when button clicked
let (loadClick, fireLoad) ← newTriggerEvent
let loadState ← asyncOnEvent loadClick fun _ => do
  -- This runs asynchronously
  let data ← fetchDataFromServer
  pure data

-- loadState is Dyn (AsyncState String Data)
-- .loading, .success data, or .error msg</code></pre>
" }
  ]
}

/-- All 66 projects in the workspace -/
def allProjects : List Project := [
  -- Graphics (11 projects)
  { name := "Terminus", slug := "terminus", category := "Graphics", categorySlug := "graphics",
    description := "Terminal user interface (TUI) library for building interactive terminal applications" },
  { name := "Afferent", slug := "afferent", category := "Graphics", categorySlug := "graphics",
    description := "Metal GPU rendering framework with Arbor/Canopy widget system for macOS" },
  { name := "Afferent Demos", slug := "afferent-demos", category := "Graphics", categorySlug := "graphics",
    description := "Demo runner and examples for the Afferent graphics framework" },
  { name := "Trellis", slug := "trellis", category := "Graphics", categorySlug := "graphics",
    description := "CSS-style layout engine for UI positioning and sizing" },
  { name := "Tincture", slug := "tincture", category := "Graphics", categorySlug := "graphics",
    description := "Color manipulation library with support for various color spaces" },
  { name := "Chroma", slug := "chroma", category := "Graphics", categorySlug := "graphics",
    description := "Interactive color picker application built with Afferent" },
  { name := "Assimptor", slug := "assimptor", category := "Graphics", categorySlug := "graphics",
    description := "3D model loading via Assimp library bindings" },
  { name := "Worldmap", slug := "worldmap", category := "Graphics", categorySlug := "graphics",
    description := "Map rendering and visualization application" },
  { name := "Vane", slug := "vane", category := "Graphics", categorySlug := "graphics",
    description := "Terminal emulator implementation" },
  { name := "Raster", slug := "raster", category := "Graphics", categorySlug := "graphics",
    description := "Image loading and manipulation library" },
  { name := "Grove", slug := "grove", category := "Graphics", categorySlug := "graphics",
    description := "File browser application with graphical interface" },

  -- Web (7 projects)
  { name := "Loom", slug := "loom", category := "Web", categorySlug := "web",
    description := "Full-featured web framework for building server-side applications" },
  { name := "Citadel", slug := "citadel", category := "Web", categorySlug := "web",
    description := "HTTP server with TLS support and middleware architecture" },
  { name := "Herald", slug := "herald", category := "Web", categorySlug := "web",
    description := "HTTP request/response parser" },
  { name := "Scribe", slug := "scribe", category := "Web", categorySlug := "web",
    description := "Type-safe HTML builder with composable elements" },
  { name := "Markup", slug := "markup", category := "Web", categorySlug := "web",
    description := "HTML parser for processing web content" },
  { name := "Chronicle", slug := "chronicle", category := "Web", categorySlug := "web",
    description := "Structured logging library with multiple output formats" },
  { name := "Stencil", slug := "stencil", category := "Web", categorySlug := "web",
    description := "Handlebars-style template engine" },

  -- Network (6 projects)
  { name := "Wisp", slug := "wisp", category := "Network", categorySlug := "network",
    description := "HTTP client library with curl bindings" },
  { name := "Legate", slug := "legate", category := "Network", categorySlug := "network",
    description := "gRPC client and server implementation" },
  { name := "Protolean", slug := "protolean", category := "Network", categorySlug := "network",
    description := "Protocol Buffers serialization library" },
  { name := "Oracle", slug := "oracle", category := "Network", categorySlug := "network",
    description := "OpenRouter API client for AI model access" },
  { name := "Jack", slug := "jack", category := "Network", categorySlug := "network",
    description := "Socket programming library for TCP/UDP" },
  { name := "Exchange", slug := "exchange", category := "Network", categorySlug := "network",
    description := "Peer-to-peer chat application" },

  -- Data (14 projects)
  { name := "Ledger", slug := "ledger", category := "Data", categorySlug := "data",
    description := "Fact-based database with Datalog-style queries" },
  { name := "Quarry", slug := "quarry", category := "Data", categorySlug := "data",
    description := "SQLite bindings and database operations" },
  { name := "Chisel", slug := "chisel", category := "Data", categorySlug := "data",
    description := "SQL DSL for type-safe query building" },
  { name := "Cellar", slug := "cellar", category := "Data", categorySlug := "data",
    description := "Disk-based caching system" },
  { name := "Collimator", slug := "collimator", category := "Data", categorySlug := "data",
    description := "Profunctor optics library (lenses, prisms, traversals)" },
  { name := "Convergent", slug := "convergent", category := "Data", categorySlug := "data",
    description := "Conflict-free replicated data types (CRDTs)" },
  { name := "Reactive", slug := "reactive", category := "Data", categorySlug := "data",
    description := "Functional reactive programming (FRP) library",
    documentation := some reactiveDoc },
  { name := "Tabular", slug := "tabular", category := "Data", categorySlug := "data",
    description := "CSV parsing and generation" },
  { name := "Entity", slug := "entity", category := "Data", categorySlug := "data",
    description := "Entity-component-system (ECS) architecture" },
  { name := "Totem", slug := "totem", category := "Data", categorySlug := "data",
    description := "TOML configuration file parser" },
  { name := "Tileset", slug := "tileset", category := "Data", categorySlug := "data",
    description := "Map tile management and caching" },
  { name := "Galaxy Gen", slug := "galaxy-gen", category := "Data", categorySlug := "data",
    description := "Galaxy generation algorithms (planned)" },

  -- Apps (16 projects)
  { name := "Homebase App", slug := "homebase-app", category := "Apps", categorySlug := "apps",
    description := "Personal dashboard application with multiple modules" },
  { name := "Todo App", slug := "todo-app", category := "Apps", categorySlug := "apps",
    description := "Task management application" },
  { name := "Enchiridion", slug := "enchiridion", category := "Apps", categorySlug := "apps",
    description := "Reference manual and knowledge base application" },
  { name := "Lighthouse", slug := "lighthouse", category := "Apps", categorySlug := "apps",
    description := "Project monitoring and status dashboard" },
  { name := "Blockfall", slug := "blockfall", category := "Apps", categorySlug := "apps",
    description := "Tetris-style falling blocks game" },
  { name := "Twenty48", slug := "twenty48", category := "Apps", categorySlug := "apps",
    description := "2048 puzzle game" },
  { name := "Ask", slug := "ask", category := "Apps", categorySlug := "apps",
    description := "CLI tool for AI-powered queries" },
  { name := "Cairn", slug := "cairn", category := "Apps", categorySlug := "apps",
    description := "Graphical application with Metal rendering" },
  { name := "Minefield", slug := "minefield", category := "Apps", categorySlug := "apps",
    description := "Minesweeper game" },
  { name := "Solitaire", slug := "solitaire", category := "Apps", categorySlug := "apps",
    description := "Card solitaire game" },
  { name := "Tracker", slug := "tracker", category := "Apps", categorySlug := "apps",
    description := "Issue tracking CLI tool" },
  { name := "Timekeeper", slug := "timekeeper", category := "Apps", categorySlug := "apps",
    description := "Time tracking TUI application" },
  { name := "Eschaton", slug := "eschaton", category := "Apps", categorySlug := "apps",
    description := "Grand strategy game with Afferent graphics" },
  { name := "Chatline", slug := "chatline", category := "Apps", categorySlug := "apps",
    description := "Chat application" },
  { name := "Astrometry", slug := "astrometry", category := "Apps", categorySlug := "apps",
    description := "Astronomy calculations (planned)" },

  -- Util (11 projects)
  { name := "Parlance", slug := "parlance", category := "Util", categorySlug := "util",
    description := "CLI argument parsing and command-line interface framework" },
  { name := "Staple", slug := "staple", category := "Util", categorySlug := "util",
    description := "Utility macros and common functionality" },
  { name := "Chronos", slug := "chronos", category := "Util", categorySlug := "util",
    description := "Date and time handling library" },
  { name := "Rune", slug := "rune", category := "Util", categorySlug := "util",
    description := "Regular expression library" },
  { name := "Sift", slug := "sift", category := "Util", categorySlug := "util",
    description := "Parser combinator library" },
  { name := "Conduit", slug := "conduit", category := "Util", categorySlug := "util",
    description := "Channel-based concurrency primitives" },
  { name := "Docgen", slug := "docgen", category := "Util", categorySlug := "util",
    description := "Documentation generation tool" },
  { name := "Tracer", slug := "tracer", category := "Util", categorySlug := "util",
    description := "Debugging and tracing utilities" },
  { name := "Crypt", slug := "crypt", category := "Util", categorySlug := "util",
    description := "Cryptographic operations via libsodium" },
  { name := "Timeout", slug := "timeout", category := "Util", categorySlug := "util",
    description := "Timeout and deadline handling" },
  { name := "Smalltalk", slug := "smalltalk", category := "Util", categorySlug := "util",
    description := "Smalltalk interpreter implementation" },

  -- Math (2 projects)
  { name := "Linalg", slug := "linalg", category := "Math", categorySlug := "math",
    description := "Linear algebra with vectors and matrices" },
  { name := "Measures", slug := "measures", category := "Math", categorySlug := "math",
    description := "Units of measurement and conversions" },

  -- Audio (1 project)
  { name := "Fugue", slug := "fugue", category := "Audio", categorySlug := "audio",
    description := "Audio synthesis and sound generation" },

  -- Testing (1 project)
  { name := "Crucible", slug := "crucible", category := "Testing", categorySlug := "testing",
    description := "Testing framework with assertions and test runners" }
]

/-- Get projects by category slug -/
def projectsByCategory (categorySlug : String) : List Project :=
  allProjects.filter (·.categorySlug == categorySlug)

/-- Find a project by slug -/
def findProject (slug : String) : Option Project :=
  allProjects.find? (·.slug == slug)

/-- Find category name by slug -/
def findCategoryName (slug : String) : Option String :=
  categories.find? (·.2 == slug) |>.map (·.1)

/-- Count projects in each category -/
def categoryProjectCounts : List (String × String × Nat) :=
  categories.map fun (name, slug) =>
    (name, slug, (projectsByCategory slug).length)

end Docsite.Data.Projects
