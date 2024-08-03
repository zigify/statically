pub const License = struct {
    /// Name of the license.
    name: []const u8,
    /// SPDX ID
    spdx: ?[]const u8,
    /// Is this license considered Open Source (OSI Approved)?
    /// https://opensource.org/licenses
    open_source: bool,
    /// Does this license infect other codebases?
    /// e.g. GPL (always) or LGPL (when statically compiling)
    infectious: bool,
    /// Does this license allow for commerical use?
    commercial_use: bool,
    /// Does this license allow for private use?
    private_use: bool,
    /// Does this license require source attribution and/or license notices?
    disclose_source: bool,
    /// Is this license superseded?
    superseded: bool,

    /// The MIT License
    /// https://opensource.org/license/mit
    pub const MIT = License{
        .name = "MIT License",
        .spdx = "MIT",
        .open_source = true,
        .infectious = false,
        .commercial_use = true,
        .private_use = true,
        .disclose_source = true,
        .superseded = false,
    };

    /// The Mozilla Public License 1.1
    /// https://opensource.org/license/mpl-1-1
    pub const MPL1_1 = License{
        .name = "Mozilla Public License 1.1",
        .spdx = "MPL-1.1",
        .open_source = true,
        .infectious = false,
        .commercial_use = true,
        .private_use = true,
        .disclose_source = true,
        .superseded = true,
    };

    /// The Mozilla Public License 2.0
    /// https://opensource.org/license/mpl-2-0
    pub const MPL2 = License{
        .name = "Mozilla Public License 2.0",
        .spdx = "MPL-2.0",
        .open_source = true,
        .infectious = false,
        .commercial_use = true,
        .private_use = true,
        .disclose_source = true,
        .superseded = false,
    };

    /// The GNU General Public License (Version 2.0)
    /// https://opensource.org/license/gpl-2-0
    ///
    /// Note about infectious: This license requires any
    /// code that is linked to it to also be released under
    /// a GPL-compatible license.
    pub const GPL2 = License{
        .name = "GNU General Public License version 2",
        .spdx = "GPL-2.0",
        .open_source = true,
        .infectious = true,
        .commercial_use = true,
        .private_use = true,
        .disclose_source = true,
        .superseded = false,
    };

    /// The GNU Lesser General Public License (Version 2.0)
    /// https://opensource.org/license/lgpl-2-0-only
    ///
    /// Note about infectious: This license requires any
    /// code that is *STATICALLY* linked to it to also be released under
    /// a GPL-compatible license. Any code that is dynamically linked is fine.
    pub const LGPL2 = License{
        .name = "GNU Lesser General Public License version 2",
        .spdx = "LGPL-2.0-only",
        .open_source = true,
        .infectious = true,
        .commercial_use = true,
        .private_use = true,
        .disclose_source = true,
        .superseded = false,
    };

    /// The GNU General Public License (Version 3.0)
    /// https://opensource.org/license/gpl-3-0
    ///
    /// Note about infectious: This license requires any
    /// code that is linked to it to also be released under
    /// a GPL-compatible license.
    pub const GPL3 = License{
        .name = "GNU General Public License version 3",
        .spdx = "GPL-3.0",
        .open_source = true,
        .infectious = true,
        .commercial_use = true,
        .private_use = true,
        .disclose_source = true,
        .superseded = false,
    };

    /// The GNU Lesser General Public License (Version 3.0)
    /// https://opensource.org/license/lgpl-3-0-only
    ///
    /// Note about infectious: This license requires any
    /// code that is *STATICALLY* linked to it to also be released under
    /// a GPL-compatible license. Any code that is dynamically linked is fine.
    pub const LGPL3 = License{
        .name = "GNU Lesser General Public License version 3",
        .spdx = "LGPL-3.0-only",
        .open_source = true,
        .infectious = true,
        .commercial_use = true,
        .private_use = true,
        .disclose_source = true,
        .superseded = false,
    };
};
