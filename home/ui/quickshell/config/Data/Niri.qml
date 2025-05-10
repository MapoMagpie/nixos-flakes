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
//     {
//       "id": 6,
//       "idx": 5,
//       "name": null,
//       "output": "DP-3",
//       "is_active": false,
//       "is_focused": false,
//       "active_window_id": null
//     },
//     {
//       "id": 7,
//       "idx": 2,
//       "name": null,
//       "output": "HDMI-A-1",
//       "is_active": false,
//       "is_focused": false,
//       "active_window_id": null
//     },
//     {
//       "id": 2,
//       "idx": 1,
//       "name": "NETW",
//       "output": "DP-3",
//       "is_active": false,
//       "is_focused": false,
//       "active_window_id": 54
//     },
//     {
//       "id": 1,
//       "idx": 1,
//       "name": "EXTE",
//       "output": "HDMI-A-1",
//       "is_active": true,
//       "is_focused": false,
//       "active_window_id": null
//     },
//     {
//       "id": 3,
//       "idx": 2,
//       "name": "CODE",
//       "output": "DP-3",
//       "is_active": true,
//       "is_focused": true,
//       "active_window_id": 56
//     },
//     {
//       "id": 4,
//       "idx": 3,
//       "name": "CHAT",
//       "output": "DP-3",
//       "is_active": false,
//       "is_focused": false,
//       "active_window_id": null
//     }
//   ]
// }
