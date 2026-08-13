# Notes

- we need to prevent Supabase from spreading accross the app, so Supabase is present only in Services implementations

- view model is responsible for navigation, yet is not dependent on SwiftUI:
  - viewmodel uses Navigator protocol, which is given to what screen should navigate (represented by enum)
  - there is separate Navigation SwiftUI view, which listens for notification from Navigator implementation and creates corresponding view

Future improvements:
 - creating repository which will hold accomodations 
 - every feature has its own target, with defined swift API (protocols and entities)
 - adding dependency injection container
