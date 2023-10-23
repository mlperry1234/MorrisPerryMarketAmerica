# MorrisPerryMarketAmerica
Code Assesment Application for Market America

Bonus Store App

Bonus Store App is a revolutionary Flutter based Mobile app, allowing loyal shop.com users to use their Bonus Points in an exciting way--by changing the Name, Description, Quantity, Price, even the cover Image of any product that they want.  

To create this app. A diagram was made, outlining the basic work flow of the app
<img width="1258" alt="Screen Shot 2023-10-23 at 7 02 46 PM" src="https://github.com/mlperry1234/MorrisPerryMarketAmerica/assets/35576248/bda9067f-b074-432d-aed5-9570352acc1c">

Next, basic pieces of the app were created, to guage the level of work that would be needed for each section. 
  + A basic app screen widget was created
  + Sample JSON response code was parsed
  + A sample API call was made
  + A permissions check was implemented
  + A small pop up test message was generated
  + A sample Local Storage session was read and written to

Once it was confirmed that the basic functionality of each feature was in place, work began on creating the data which would be used throughout the app
  + Product Detail, Category, and General classes were made
  + User Data classes were made
  + API values, such as API Key and web URI were established

Once the overall data structures were set, the basic Screens and their navigation was set
  + Navigation container was put in place, which routed the Home, Search, and Account screen
  + The individual screens were created, Login, Home, Search, Account, and Product Details
  + Basic functionality inbetween screens was put in place, such as going from Search to Product Details, and from Account to the Login Screen via the Log out button

Next, the API and JSON parsing functionality was put in place, building from the previous samples
  + The API calls for getting Products, Product Categories, and Product Details was in place
  + The saving of Login data to local storage
  + Parsing JSON data from the API calls

Next, Data Population and Conditional Interactivity was done
  + Data from JSON calls populated the various screens
  + Conditional Interactivity was implemented, such as Disabling the Login button if the form was incomplete
  + More classes and variables were set when needed to ensure the new functionality

At this point, User Testing began to ensure that the app was functional. 

Finally, the details were added to enhance user experience
  + Translation support was added
  + Color scheme was set
  + User feedback such as SnackBar was implemented
  + Directions, feedback, and other important text was added


The final APK can be found or here

Thank you for reviewing the Bonus Store App!
Morris Perry
  
