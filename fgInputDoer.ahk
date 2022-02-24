/*
    Just a moderate amount of trolling. A smidge of tomfoolery. 
    A tiny bit of misbehavior. Merely a little fooling around.
    A microscopic value of pranking.

    Outputs FG inputs at the press of one key because i can't be fucked to
    learn them. 
 */


; EVERYTHING NOT PRECEDED BY A SEMICOLON
/* 
    OR SURROUNDED BY THESE 
*/
; IS PART OF THE SCRIPT,
; SO CHANGE WITH CAUTION.


; All directional keys
; If you wanna change them, put them in the following order:
; Up, Left, Down, Right
global allDirectionKeys := ["w", "a", "s", "d"]


; First argument of this function sets a delay
; between keypresses, and the second the duration of each
; press. Both are in miliseconds. Insufficient press
; duration could make some inputs not go through,
; so if you get inconsistent inputs try changing this.
SetKeyDelay, 25, 20


/*
    The actual character inputs.
    Use numpad notation + a dot between
    directional and attack inputs.
*/
;------------------------------------------
potFDB := "624.S"
potMegaFist := "26.P"
potBuster := "624-6.P"
potHeatKnuckle := "6<26.H"
potSlidehead := "26.S"
potJudgeGauntlet := "624.D"
potGiganter := "624-6.H"
potHeavenlyBuster := "26-26.S"
;------------------------------------------

/*
    Here are the actual mappings.
    To see the name of the key you want,
    see the keylist in here:
    https://www.autohotkey.com/docs/KeyList.htm
*/
;------------------------------------------
NumpadMult::performInput(potFDB)
NumpadDiv::performInput(potMegaFist)
NumpadSub::performInput(potHeatKnuckle)
Space::performInput(potHeavenlyBuster)
f::performInput(potBuster)
Tab::performInput(potGiganter)
;------------------------------------------

/*
    Perform an input given its 
    notation string.
*/
performInput(moveInputs) {
    ; Get held key state before blocking input
    aHeld := GetKeyState("a", "P")
    dHeld := GetKeyState("d", "P")

    BlockInput, On
    releaseDirections()

    ; Use input only if a direction is held
    if (aHeld) {
        reversedInput := reverseDirNotation(moveInputs)
        parseDirectionalInput(reversedInput)
    } else if (dHeld) {
        parseDirectionalInput(moveInputs)
    } else {
        return
    }

    BlockInput, Off
}

/* 
    Get actual keystrokes from
    the input notation and press them.
*/
parseDirectionalInput(note) {
    ; Get directional input array from notation
    dirInputs := dirArrayFromNotation(note)
    pressDirInput(dirInputs, 1, False)
    ; Get attack input from notation
    attackInput := StrSplit(note, ".")[2]
    parseAttackInput(attackInput)
}
; Will maybe use variables for this later. IDK.
parseAttackInput(attackInput) {
    switch (attackInput) {
        Case "P":
            Send {Numpad7 Down}{Numpad7 Up}
        Case "K":
            Send {Numpad8 Down}{Numpad8 Up}
        Case "S":
            Send {Numpad9 Down}{Numpad9 Up}
        Case "H":
            Send {Numpad4 Down}{Numpad4 Up}
        Case "D":
            Send {Numpad6 Down}{Numpad6 Up}
    }
}

/*
    Press all keys inside a
    directional input array.
*/
; Still not working properly but at least its working.
pressDirInput(array, curIndex, secondPass := False) {
    ; If at last index, STOP RECURSION CHRIST
    curInput := array[curIndex]
    if (curIndex == getArrayLength(array)) {
        if (curIndex == 1) {
            Send {%curInput% Down}
            releaseDirections()
            return
        }
        else if (!secondPass) {
            return pressDirInput(array, 1, True)
        }
        else if (secondPass) {
            releaseDirections()
            return
        }
    }

    lastInput := array[curIndex - 1]
    if (curInput == "<") {
        Send {%lastInput% Up}
        return pressDirInput(sliceArray(array, curIndex + 1), 1)
    }

    if (curInput == "-") {
        pressDirInput(sliceArray(array, 1, curIndex - 1), 1, True)
        return pressDirInput(sliceArray(array, curIndex + 1), 1)
    }
    else if (!secondPass) {
        Send {%curInput% Down}
        return pressDirInput(array, curIndex + 1)
    } 
    else if (secondPass) {
        Send {%curInput% Up}
        return pressDirInput(array, curIndex + 1, True)
    }
}


;------------------------------------------
;       Literally just
;     Utility functions wow
;------------------------------------------

/* 
    From 2 directional input strings,
    get the keys that dont overlap.
*/
getExclusiveKeys(keyPair, loneKey) {
    Loop, Parse, keyPair
        If A_LoopField != loneKey
            return A_LoopField
}

; taken from 
; https://www.autohotkey.com/boards/viewtopic.php?t=76049
sliceArray(arr, start, end := ""){
	len := arr.Length()
	if(end == "" || end > len)
		end := len
	if(start<arr.MinIndex())
		start := arr.MinIndex()
	if(len<=0 || len < start || start > end)
		return []
		
	ret := []
	start -= 1
	c := end - start
	loop %c%
		ret.push(arr[A_Index + start])
	return ret
}

/*
    Check if str is inside array
*/
strInArray(str, array) {
    for key, value in array
        If value = str
            return True
    return False
}
 
/* 
    Get an array of strings that
    can be used with Send from an
    input notation string
*/
dirArrayFromNotation(note) {
    dirArray := []
    Loop, Parse, note
        switch (A_LoopField) {
            Case 6:
                dirArray.Push("d")
            Case 3:
                dirArray.Push("sd")
            Case 2:
                dirArray.Push("s")
            Case 1:
                dirArray.Push("sa")
            Case 4:
                dirArray.Push("a")
            Case 7:
                dirArray.Push("aw")
            Case 8:
                dirArray.Push("w")
            Case 9:
                dirArray.Push("wd")
            Case "-":
                dirArray.Push("-")
            Case "<":
                dirArray.Push("<")
        }
    return dirArray
}

/* 
    Reverse the notation for directional inputs, so
    i dont need to manually type the reversed versions.
*/
reverseDirNotation(note) {
    notationArray := StrSplit(note, ".")
    reversedNotation := ""
    notation := notationArray[1]
    ; StrReplace is not working so... hah
    Loop, Parse, notation
        switch (A_LoopField) {
            Case 6:
                reversedNotation .= "4"
            Case 4:
                reversedNotation .= "6"
            Case 1:
                reversedNotation .= "3"
            Case 3:
                reversedNotation .= "1"
            Default:
                reversedNotation .= A_LoopField
        }
    return reversedNotation . "." . notationArray[2]
}

/* 
    Get length of an array
*/
getArrayLength(array) {
    len := 1
    for key, value in array
        len++
    return len
}

/* 
    Release all movement keys.
*/
releaseDirections() {
    for index, direction in allDirectionKeys {
        if GetKeyState(direction) {
            Send {%direction% Up}
        }
    }
}