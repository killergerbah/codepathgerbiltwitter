# Project 4 - *Gerbil Twitter*

Time spent: **10** hours spent in total

## User Stories

The following **required** functionality is completed:

- [ ] Hamburger menu
   - [ ] Dragging anywhere in the view should reveal the menu.
   - [ ] The menu should include links to your profile, the home timeline, and the mentions view.
   - [ ] The menu can look similar to the example or feel free to take liberty with the UI.
- [ ] Profile page
   - [ ] Contains the user header view
   - [ ] Contains a section with the users basic stats: # tweets, # following, # followers
- [ ] Home Timeline
   - [ ] Tapping on a user image should bring up that user's profile page

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

  1. How did others design navigation? For some reason it felt natural to implement a back button for navigating between different items on the menu but that ended up being incredibly tedious to do.
  2. Generally how to reuse view controller code without having to control-drag more or less the same things over and over again just to duplicate code that already existed in the same form.


## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/XX572ne.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

1. I found it incredibly difficult to reuse UI code without implementing a lot of state within the view controller itself i.e. some kind of type enum to display different things using more or less the same code. 

2. To support a back button, I ended up having to make assumptions about the view controllers I was having the hamburger menu view controller manage - namely that they were UINavigationControllers and that the navigation controllers' visible view controllers were the ones I really cared about. Managing this tree of controllers is really frustrating and I can't think of a more consistent way to do it.

## License

    Copyright [2016] [Gerbil Tech]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
