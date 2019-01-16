// MessageBox.java - Copyright 2019 by Stewart~Frazier Tools, Inc.
//
// Permission to use this sample code as you see fit, as long as
// you do not claim authorship.  The original 'author' for the code
// that this was 'derived' from would have been someone answering
// questions on line, probably in 'Stack Overflow' or an Android
// related blog site.  Quite frankly, I really don't remember except
// that I adapted THAT code [making it simpler] and used it in more
// than one place after I worked the bugs and kinks out of it.
//

// you'll need to modify this next line accordingly and uncomment it
// package com.your.project;

// --------------------------------------------------------------------
// things you'll need to import shown here - add to 'import' section of
// your main activity source as needed.
// --------------------------------------------------------------------

//import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;
import android.app.AlertDialog;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.view.View;
import android.content.Context;
import android.content.DialogInterface;


// ******************************************************************************
//
// With the main activity active or in the background, you should be able to use
// the two 'message box' functions directly, since they're both static methods.
//
// If this poses a problem with different open activities, you can simply add the
// same code to those activities and call the appropriate functions from within
// the context of that activity.
//
// ******************************************************************************


// put this stuff into your 'MainActivity' class.  comments show sample class

//public class MainActivity extends AppCompatActivity
//{

  // -----------------
  // add this variable
  // -----------------
  static MainActivity mContext; // context of main activity, for dialogs

//  @Override
//protected void onCreate(Bundle savedInstanceState)
//{
//  super.onCreate(savedInstanceState);
//  setContentView(R.layout.activity_main);
//
// ...
//

    // --------------------------------------------------------------------------
    // add this line to your 'onCreate' or build one based on the commented lines
    // --------------------------------------------------------------------------
    mContext = this; // getBaseContext(); - cached context for external things to use
//}

  // -------------------------------
  // add these methods and variables
  // -------------------------------

  // 'getContext' utility to return the cached static Context for various reasons
  public static Context getContext()
  {
    return mContext;
  }

  private static boolean fResponse; // response indicator


  // 'Yes/No' dialog - originally derived from sample code found online
  //
  // displays text in dialog box, asks 'yes' or 'no', returns response
  // as 'true' for yes, 'false' for no/error.
  //
  // Execution in the thread stops until you respond to the dialog box

  public static boolean dlgYesNo(String strText)
  {
    // need a handler with 'handleMessage' callback to throw exception
    final Handler handler = new Handler( )
    {
      @Override
      public void handleMessage(Message mesg)
      {
        throw new RuntimeException( );
      }
    };

    try
    {
      fResponse = false;

      DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener( )
      {
        @Override
        public void onClick(DialogInterface dialog, int which)
        {
          switch(which)
          {
            case DialogInterface.BUTTON_POSITIVE:
              fResponse = true;
              handler.sendMessage(handler.obtainMessage( ));
              break;

            case DialogInterface.BUTTON_NEGATIVE:
              fResponse = false;
              handler.sendMessage(handler.obtainMessage( ));
              break;
          }
        }
      };

      // use builder to ad-hock make a dialog box with a YES and a NO button
      AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.getContext( ));
      builder.setMessage(mContext.stringFromJNI() + "\n" + strText).setPositiveButton("Yes", dialogClickListener)
             .setNegativeButton("No", dialogClickListener).show( );

      try
      {
        // 'Looper' will exit on exception. response stored in 'fResponse'
        // Unfortunately, this seems to be the best way to do it
        Looper.loop( );
      }
      catch (Exception e)
      {
      }

      return fResponse;
    }
    catch (Exception e)
    {

    }

    return false;
  }


  // 'OK' dialog - originally derived from sample code found online
  //
  // displays text in dialog box, user must press 'OK' to continue
  // returns 'true' for success, 'false' on error
  //
  // Execution in the thread stops until you respond to the dialog box

  public static boolean OKDialog(String strText)
  {
    // need a handler with 'handleMessage' callback to throw exception
    final Handler handler = new Handler( )
    {
      @Override
      public void handleMessage(Message mesg)
      {
        throw new RuntimeException( );
      }
    };

    try
    {
      fResponse = false; // to differentiate from error/cancel

      DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener( )
      {
        @Override
        public void onClick(DialogInterface dialog, int which)
        {
          switch(which)
          {
            case DialogInterface.BUTTON_POSITIVE:
              fResponse = true; // OK button assigns 'true' to flag
              handler.sendMessage(handler.obtainMessage( ));
              break;
          }
        }
      };

      // use 'Builder' to create an ad-hoc dialog box with an 'OK' button
      AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.getContext( ));
      builder.setMessage(mContext.stringFromJNI() + "\n" + strText).setPositiveButton("OK", dialogClickListener).show( );

      try
      {
        // 'Looper' will exit on exception. response stored in 'fResponse'
        // Unfortunately, this seems to be the best way to do it
        Looper.loop( );
      }
      catch (Exception e)
      {
      }

      return fResponse;
    }
    catch (Exception e)
    {

    }

    return false;
  }

//}
