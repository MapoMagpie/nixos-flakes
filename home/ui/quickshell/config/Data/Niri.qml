pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    // property var data
    property var workspaces: []
    property var activedWorkspace: "VOID"
    property var activedWorkspaceIndex: 0
    property var windows: []
    // property var activedWindowId: 0

    Process {
        id: proc
        command: ["niri", "msg", "-j", "event-stream"]

        running: true
        stdout: SplitParser {
            onRead: data => {
                var event = JSON.parse(data);
                let workspaces = [];
                if (event.WorkspacesChanged) {
                    root.workspaces = event.WorkspacesChanged.workspaces.filter(w => w.name);
                    root.workspaces = root.workspaces.sort((a, b) => a.id - b.id);
                    root.activedWorkspaceIndex = root.workspaces.findIndex(w => w.is_focused);
                    if (root.activedWorkspaceIndex < 0) {
                        root.activedWorkspaceIndex = 0;
                    }
                    root.activedWorkspace = root.workspaces[root.activedWorkspaceIndex].name;
                }
                if (event.WindowsChanged) {
                    root.windows = [...event.WindowsChanged.windows].sort((a, b) => a.id - b.id);
                }
                if (event.WindowOpenedOrChanged) {
                    const window = event.WindowOpenedOrChanged.window;
                    const index = root.windows.findIndex(w => w.id === window.id);
                    console.log("window opened or changed: ", index, ", win id: ", window.id);
                    if (index >= 0) {
                        console.log("replace window, old: ", root.windows[index].id, ", new: ", window.id);
                        root.windows[index] = window;
                    } else {
                        console.log("push    window, new: ", window.id);
                        root.windows.push(window);
                    }
                    root.windows = [...root.windows.sort((a, b) => a.id - b.id)];
                }
                if (event.WindowClosed) {
                    const index = root.windows.findIndex(w => w.id === event.WindowClosed.id);
                    console.log("window closed: ", index, ", win id: ", event.WindowClosed.id);
                    if (index >= 0) {
                        root.windows.splice(index, 1);
                    }
                    root.windows = [...root.windows.sort((a, b) => a.id - b.id)];
                }
                if (event.WorkspaceActivated) {
                    root.activedWorkspaceIndex = root.workspaces.findIndex(w => w.id === event.WorkspaceActivated.id);
                    if (root.activedWorkspaceIndex < 0) {
                        root.activedWorkspaceIndex = 0;
                    }
                    root.activedWorkspace = root.workspaces[root.activedWorkspaceIndex].name;
                }
            }
        }
    }
}
// {
//   "workspaces": [
//     {
//       "id": 5,
//       "idx": 4,
//       "name": "GAME",
//       "output": "DP-3",
//       "is_active": false,
//       "is_focused": false,
//       "active_window_id": null
//     },
//   ]
// }
