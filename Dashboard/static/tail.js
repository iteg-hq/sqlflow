"use strict"

let rv = null;

function setup() {
    setInterval(function(){ getTail(); }, 1000);
}

async function getTail() {
     const options = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    };
    try {
        let url;
        if(rv == null) {
            url = `/api/tail`;
        } else {
            url = `/api/tail?timestamp=${rv}`
        }
        const response = await fetch(url, options)
        const json = await response.json();
        // console.log(json)
        json.entries.forEach(addEntry);
    } catch (err) {
        console.log('Error getting documents', err)
    }
}

function addEntry(entry) {
    rv = entry.rv;
    var para = document.createElement("p");
    var entryText = document.createTextNode(formatEntry(entry));
    para.className = "LogEntry " + entry.LogLevelCode;
    if(filterEntry(entry)) {
        para.style.display = "none";
    }
    para.appendChild(entryText);
    document.getElementById("tail").appendChild(para);
    window.scrollTo(0, document.body.scrollHeight);
}

function filterEntry(entry) {
    return false; entry.LogLevelCode == 'TRACE';
}

function formatEntry(entry) {
    return `[${entry.EntryTimestamp}][${entry.LogLevelCode}][${entry.FlowID||""}][${entry.ExecutionID||""}] ${entry.FormattedEntryText}`
}